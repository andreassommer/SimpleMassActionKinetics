function writeCodeFromModel(language, model, file, baseidx)
   %
   % writeCodeFromModel(language, model, file, baseidx)
   %   
   % Generates code from model and writes it to file.  
   % Attention: OVERWRITES EXISTING FILES!
   %
   % INPUT:    language - string  
   %           model    - model structure
   %           file     - string (file name)
   %           baseidx  - integer, (number of first element, e.g. 0 or 1)
   %
   % Possible languages are:   MATLAB_SM  -->  Matlab code using "SM*rates"-notation
   %                           MATLAB_ODE -->  Matlab code using ODE-notation
   %                           FORTRAN    -->  Experimentally Fortran-Code for VPLAN
   %                           LISP       -->  LISP values with infix-notation #o
   %
   %
   % [andreas.sommer@iwr.uni-heidelberg.de - 25.05.2009]
   % [code@andreas-sommer.eu - 12.05.2022]
   % 18.05.2010 - added support for lisp-code-creation
   % 25.09.2012 - fixed: if species does not change, set it to 0    
   % 12.05.2022 - improved compatibility to newer versions of Matlab and Octave

   %#ok<*AGROW> ;; Ignore growing vectors 
   
   % .. is baseidx given? ..
   if ~exist('baseidx','var')
      baseidx = 0;   
   else
      baseidx = baseidx - 1;
   end
   
   invalidSigns = ' "!§$%&/()=°?ß+-*\/#''^´`µ@€öäüÖÄÜ~<>|²³{[]};:,.';
   
   % .. check if language is implemented ..
   language = upper(language);
   validLanguages = {'MATLAB', 'MATLAB_SM', 'MATLAB_ODE', 'VPLAN_TEST', 'FORTRAN', 'LISP'};
   if ~any(ismember(language, validLanguages))
      error('Language "%s" not supported', language);
   end
   
   % .. set some variables for feeling comfortable ..
   species      = model.species;
   reactions    = model.reactions;
   parameters   = model.parameters;
   numSpecies   = length(species);
   numReactions = length(reactions);
   
   % .. set up stoichiometry matrix by walking through species and reactions ..
   SM = zeros(numSpecies, numReactions);
   for specNum = 1:numSpecies
      for reacNum = 1:numReactions
         val = 0;
         educts   = reactions(reacNum).educts;
         products = reactions(reacNum).products;
         positionInEducts   = find(ismember(educts.names  ,species(specNum)));
         positionInProducts = find(ismember(products.names,species(specNum)));
         if ~isempty(positionInEducts),    val = val - educts.factors{positionInEducts};     end
         if ~isempty(positionInProducts),  val = val + products.factors{positionInProducts}; end
         SM(specNum, reacNum) = val;
      end
   end
   
   % .. create code needed ..
   codelines = {'';''};
   switch language
      % ======================================================> MATLAB-Code (SM) <========================================================
      case {'MATLAB_SM'}
         [pathstr, functionname, ext] = fileparts(file);
         codelines{1} = createMatlabFunctionHeader(functionname, parameters);
         codelines{2} = sprintf('%% Model:   %s',model.name);
         %%%%% write comment lines explaining species
         codelines{end+1} = '% Species:';
         for row = 1:length(species)
            codelines{end+1} = sprintf('%%   x(%02d) --> %s',row+baseidx,species{row});
         end
         %%%%% walk through rows of stoichiometry matrix
         codelines{end+1} = '';
         codelines{end+1} = '% stoichiometry matrix';
         codelines{end+1} = 'SM = [  ...';
         for row = 1:size(SM,1)  
            codelines{end+1} = ['         '  sprintf(' %3d  ',SM(row,:))  '   ; ...  '  sprintf('%% %s',species{row})];
         end
         codelines{end+1} = '     ];';
         %%%%% create replacement strings and replace species names
         numberofspecies = length(species);
         repStr = {''};
         for specNum = 1:numberofspecies
            repStr{specNum} = sprintf('x(%02d)',specNum+baseidx);
         end
         reactions = replaceStringInStructure(reactions,species,repStr,'skipfields','name');
         %%%%% set up rates vector
         codelines{end+1} = '';
         codelines{end+1} = '% rates vector';
         codelines{end+1} = 'rates = [  ...';
         startCommentLine = length(codelines)+1;
         for reacNum = 1:length(reactions)
            curReac = reactions(reacNum);
            codelines{end+1} = sprintf('    %s', curReac.rate);
            if ~isempty(curReac.modifier)
               codelines{end} = [codelines{end}  sprintf('*%s',curReac.modifier)];
            end
            if ~isempty(curReac.educts.names)
               for eductNum = 1:length(curReac.educts.names)
                  codelines{end} = [codelines{end}  sprintf('*%s^(%d)',curReac.educts.names{eductNum},curReac.educts.factors{eductNum})];
               end
            end
            codelines{end} = strrep(codelines{end},'^(1)','');  % remove xxx to the power of 1  (x^1)
         end
         codelines = replaceInString(codelines, {'-1*','+1*'}, {'- ','+ '});      % Clear code from unnecessary factors  (e.g. replace -1*p(5) by -p(5))
         codelines = addComments(codelines, startCommentLine, '   ; ... %', {reactions.name});   % add comments to rates vector
         codelines{end+1} = '        ];';
         codelines{end+1} = '';
         codelines{end+1} = '% rhs of ode';
         codelines{end+1} = 'dx = SM * rates;';
         codelines{end+1} = 'end   % end of function';
         %%%%% add indentation inside function
         for row = 2:length(codelines)-1
            codelines{row} = ['   ' codelines{row}];
         end

      % ======================================================> Matlab-Code (ODE) <========================================================         
      case {'MATLAB_ODE','MATLAB'}
         %%%%% write code of function header
         [pathstr, functionname, ext] = fileparts(file);
         codelines{1} = createMatlabFunctionHeader(functionname, parameters);
         codelines{2} = sprintf('%% Model:   %s',model.name);
         %%%%% write comment lines explaining species
         codelines{end+1} = '% Species:';
         for row = 1:length(species)
            codelines{end+1} = sprintf('%%   x(%02d) --> %s',row+baseidx,species{row});
         end
         %%%%% create replacement strings and replace species names
         numberofspecies = length(species);
         repStr = {''};
         for specNum = 1:numberofspecies
            repStr{specNum} = sprintf('x(%02d)',specNum+baseidx);
         end
         reactions = replaceStringInStructure(reactions,species,repStr,'skipfields','name');
         %%%%% set up rates vector
         ratesVector = {};
         for reacNum = 1:length(reactions)
            curReac = reactions(reacNum);
            ratesVector{end+1} = strtrim(sprintf('%s', curReac.rate)); 
            if ~isempty(curReac.modifier)
               ratesVector{end} = [ratesVector{end}  sprintf('*%s',curReac.modifier)];
            end
            if ~isempty(curReac.educts.names)
               for eductNum = 1:length(curReac.educts.names)
                  ratesVector{end} = [ratesVector{end}  sprintf('*%s^(%d)',curReac.educts.names{eductNum},curReac.educts.factors{eductNum})];
               end
            end
            ratesVector{end} = strrep(ratesVector{end},'^(1)','');  % remove xxx to the power of 1  (x^1)
         end
         %%%%% form rhs of ODE
         codelines{end+1} = sprintf('dx = zeros(%d,1);',length(species)+max(0,baseidx-1));
         startCommentLine = length(codelines) + 1;
         for specNum = 1:length(species)
            dxcode = sprintf('dx(%02d) = ',specNum+baseidx);
            codelines{end+1} = dxcode;
            for reacNum = 1:length(reactions)
               SMfactor = SM(specNum, reacNum);
               if ~(SMfactor==0)
                  codelines{end} = [codelines{end}  sprintf(' %+3d',SMfactor) '*' ratesVector{reacNum} ];
               end
            end
            if (strcmp(codelines{end}, dxcode))  % i.e. species involved in no reaction
               codelines{end} = [codelines{end} '0'];
            end
         end
         codelines = replaceInString(codelines, {'-1*','+1*'}, {'- ','+ '});       % Clear code from unnecessary factors  (e.g. replace -1*p(5) by -p(5))
         codelines = addComments(codelines, startCommentLine, ' ;  %', species);   % add comments to rates vector
         codelines{end+1} = 'end   % end of function';
         %%%%% add indentation inside function
         for row = 2:length(codelines)-1
            codelines{row} = ['   ' codelines{row}];
         end

      % =====================================================> VPLAN (Fortran 77) <========================================================         
      case {'VPLAN_TEST', 'FORTRAN'}
         %%%%% create replacement strings and replace species names in reactions
         numberofspecies = length(species);
         repStr = {''};
         for specNum = 1:numberofspecies
            repStr{specNum} = sprintf('x(%02d)',specNum+baseidx);
         end
         reactions = replaceStringInStructure(reactions,species,repStr,'skipfields','name');
         %%%%% write init comments
         codelines{1} = sprintf('! Differential right-hand-side function.');
         codelines{2} = sprintf('! Model:   %s',model.name);
         %%%%% write comment lines explaining species
         codelines{end+1} = '! ';         
         codelines{end+1} = '! Species:';
         for row = 1:length(species);
            codelines{end+1} = sprintf('!   x(%02d) --> %s',row+baseidx,species{row});
         end
         indentationStartLine = length(codelines) + 1;
         %%%%% write code of function header
         functionname = removeCharsFromString(model.name,invalidSigns);
         codelines{end+1} = ' ';
         codelines{end+1} = sprintf('subroutine %s_01_f( t, x, f, p, q, rwh, iwh, iflag )',functionname);
         codelines{end+1} = ' ';
         codelines{end+1} = 'implicit none';
         codelines{end+1} = 'real*8 x(*), f(*), p(*), q(*), rwh(*), t, mf';
         codelines{end+1} = 'integer*4 iwh(*), iflag';
         codelines{end+1} = ' ';
         codelines{end+1} = '!DISCRETIZE1(mf, q, rwh, iwh)';
         codelines{end+1} = ' ';
         codelines{end+1} = ' ';
         %%%%% set up rates vector
         ratesVector = {};
         for reacNum = 1:length(reactions)
            curReac = reactions(reacNum);
            ratesVector{end+1} = strtrim(sprintf('%s', curReac.rate));
            if ~isempty(curReac.modifier)
               ratesVector{end} = [ratesVector{end}  sprintf('*%s',curReac.modifier)];
            end
            if ~isempty(curReac.educts.names)
               for eductNum = 1:length(curReac.educts.names)
                  ratesVector{end} = [ratesVector{end}  sprintf('*%s**(%d)',curReac.educts.names{eductNum},curReac.educts.factors{eductNum})];
               end
            end
            ratesVector{end} = strrep(ratesVector{end},'**(1)','');  % remove xxx to the power of 1  (x^1)            
         end
         %%%%% form rhs of ODE
         startCommentLine = length(codelines) + 1;
         for specNum = 1:length(species)
            dxcode = sprintf('f(%d) = ',specNum+baseidx);
            codelines{end+1} = dxcode;
            for reacNum = 1:length(reactions)
               SMfactor = SM(specNum, reacNum);
               if ~(SMfactor==0)
               codelines{end} = [codelines{end}  sprintf(' %+3d',SMfactor) '*' ratesVector{reacNum} ];
               end
            end
            %%%% codelines{end} = [codelines{end}  '      ! '  species{specNum}];
            if (strcmp(codelines{end}, dxcode))  % i.e. species involved in no reaction
               codelines{end} = [codelines{end} '0'];
            end
         end
         codelines = replaceInString(codelines, {'-1*','+1*'}, {'- ','+ '});      % Clear code from unnecessary factors  (e.g. replace -1*p(5) by -p(5))
         codelines = addComments(codelines, startCommentLine, '   !', species);   % add comments to rates vector
         %%%%% finish function
         codelines{end+1} = ' ';
         codelines{end+1} = 'end';
         %%%%% add indentation inside function
         for row = indentationStartLine:length(codelines)
            codelines{row} = ['      ' codelines{row}];
         end

      % =====================================================> LISP (Ansi CommonLisp) <========================================================         
      case 'LISP'
         %%%%% write init comments
         codelines{1} = sprintf(';; Differential right-hand-side function.');
         codelines{2} = sprintf(';; Model:   %s',model.name);
         %%%%% write comment lines explaining rate parameters
         codelines{end+1} = ';; ';         
         codelines{end+1} = ';; Reactions:';
         for row = 1:length(reactions);
            %%%%% remove parenthesis in rates 
            reactions(row).rate = replaceInString(reactions(row).rate, {'(',')','[',']'}, {'','','',''});
            codelines{end+1} = sprintf(';;  %s --> %s',reactions(row).rate,reactions(row).name);
         end
         indentationStartLine = length(codelines) + 1;
         %%%%% write code of function header
         functionname = removeCharsFromString(model.name,invalidSigns);
         codelines{end+1} = '';         
         codelines{end+1} = '';         
         codelines{end+1} = ';; quoted list of right hand side ';
         codelines{end+1} = '''(values ';
         %%%%% set up rates vector
         ratesVector = {};
         for reacNum = 1:length(reactions)
            curReac = reactions(reacNum);
            ratesVector{end+1} = strtrim(sprintf(' %s', curReac.rate));
            if ~isempty(curReac.modifier)
               ratesVector{end} = [ratesVector{end}  sprintf(' * %s',curReac.modifier)];
            end
            if ~isempty(curReac.educts.names)
               for eductNum = 1:length(curReac.educts.names)
                  ratesVector{end} = [ratesVector{end}  sprintf(' * %s**(%d)',curReac.educts.names{eductNum},curReac.educts.factors{eductNum})];
               end
            end
            ratesVector{end} = strrep(ratesVector{end},'**(1)','');  % remove xxx to the power of 1  (x^1)            
         end
         %%%%% form rhs of ODE
         startCommentLine = length(codelines) + 1;
         for specNum = 1:length(species)
            codelines{end+1} = sprintf('    #i(');
            for reacNum = 1:length(reactions)
               SMfactor = SM(specNum, reacNum);
               if ~(SMfactor==0)
               codelines{end} = [codelines{end}  sprintf('  %+3d',SMfactor) ' * ' ratesVector{reacNum} ];
               end
            end
            codelines{end} = [codelines{end} ' )'];
         end
         codelines = replaceInString(codelines, {'-1 * ','+1 * '}, {'- ','+ '});      % Clear code from unnecessary factors  (e.g. replace -1*p(5) by -p(5))
         codelines = addComments(codelines, startCommentLine, '  ;;', species);   % add comments to rates vector
         %%%%% finish function
         codelines{end+1} = ')'; % closes "(values ...)"
         codelines{end+1} = ' ';
         %%%%% Write quoted list of species
         codelines{end+1} = ';; quoted list of species';
         codelines{end+1} = '''(';
         for specNum = 1:length(species)
            codelines{end} = [codelines{end} ' ' species{specNum} ' '];
         end
         codelines{end} = [codelines{end} ')'];
         codelines{end+1} = ' ';
         %%%%% Write quotes list of rates with initial value of 0.01d0
         codelines{end+1} = ';; quoted list of rates';
         codelines{end+1} = '''(';
         uniqueRateNames = unique({reactions.rate});
         for i = 1:length(uniqueRateNames)
            codelines{end} = [codelines{end} ' (' uniqueRateNames{i} ' 0.01d0' ')' ];
         end
         codelines{end} = [codelines{end} ')'];
         codelines{end+1} = ' ';

         
         
      % ==========================> Error <==============================      
      otherwise
         error('Something terrible has happened!');
   end

 
   % write code to file
   try
      fid = fopen(file,'w');
      for row = 1:length(codelines)
         fprintf(fid,'%s\n',codelines{row});
      end
      fclose(fid);
   catch ME
      disp('WARNING: Error writing to file.');
      disp(ME.stack);
      disp('ENDOFWARNING');
   end 
   
   % Make sure, that matlab gets to know this newly created file.
   % It's a BUG, not a Feature!
   if ~exist(file), disp('WARNING: File disappeared!'); end
   
end




%%%%% ================================= Helper function ==============================
function newCodeLines = addComments(codelines, startline, commentsign, comments)
   % function newCodelines = addComments(codelines, startline, commentsign, comments)
   %
   % Adds comments to codelines.
   %
   % INPUT:         codelines   -  cell array of strings
   %                startline   -  scalar     (number of first line to comment)
   %              commentsign   -  string     (comment sign)
   %                 comments   -  cell array of strings   (comments)
   %
   % OUTPUT:     newCodelines   -  cell array of strings   (commented code)
   %
   
   % comments must be a cell array of strings:
   comments = cellstr(comments);
   
   % get length of longest line
   maxlength = 0;
   for k = startline:(startline+length(comments)-1)
      maxlength = max(maxlength, length(codelines{k}));
   end
   maxlength = maxlength + 1;
   
   % insert comments
   for k = 1:length(comments)
      codelines{startline-1+k}(maxlength) = ' ';
      codelines{startline-1+k} = [codelines{startline-1+k}   sprintf('%s %s',commentsign,comments{k})];
      codelines{startline-1+k}(find(codelines{startline-1+k}==0)) = ' ';   % replace &0h by space character
   end
   
   newCodeLines = codelines;
   
end

function string = createMatlabFunctionHeader(functionname, parameters)
   string = [  sprintf('function dx = %s(t,x',functionname)       sprintf(',%s',parameters{:})   ] ;
   if (string(end)==','), string = string(1:end-1); end;  % remove comma at end if needed
   string = [string  ', varargin)'];
end












