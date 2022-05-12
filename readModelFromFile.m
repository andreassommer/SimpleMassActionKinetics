function model = readModelFromFile(filename)
   % function model = readModelFromFile(filename)
   %
   % Reads model from model description file
   %
   % INPUT:       filename  - string
   %
   % OUPUT:          model  - model structure
   %
   %
   % [andreas.sommer@iwr.uni-heidelberg.de - 25.05.2009]
   % [code@andreas-sommer.eu - 12.05.2022]
   % Update: 12.05.2022 - Improved compatibility to newer Matlab and Octave
   
   % set delimiters:
   delimComment   = '!';
   delimParts     = ':=>';
   delimReactants = '+';
   delimFactors   = '*';
   delimDirective = '$';
   delimModelName = [delimDirective 'MODEL'];
   delimSpecies   = [delimDirective 'SPECIES'];
   delimParameter = [delimDirective 'PARAMETER'];
   delimReaction  = [delimDirective 'REACTION'];

   % spaces and tabs are white space
   whiteSpace = sprintf(' \t');     
   
   % check if file exists
   if ~exist(filename,'file')
      error('ERROR: File "%s" does not exist.',filename);
   end
   
   % read complete file into memory
   try
      fid = fopen(filename,'r');
      k = 0;
      while ~feof(fid)
         k = k + 1;
         modelstrings{k} = fgetl(fid);   %#ok<AGROW>  we cannot preallocate
      end
      fclose(fid);
   catch ME
      try %#ok<TRYNC>
         fclose(fid);
      end
      disp(ME.stack);
   end
   
   %%%% create model

   % init some variables
   parameters = {};
   species = {};
   reacNum = 0;
   
   % walk through modelstrings
   modelNameStr = 'nameless';
   for lineNum = 1:length(modelstrings)
      
      curStr = strtrim(modelstrings{lineNum});
      
      % Skip empty lines and comment lines
      if (isempty(removeCharsFromString(curStr,whiteSpace))),  continue;  end    
      if strncmp(curStr,delimComment,length(delimComment)), continue; end  

      % strip comments from the end of the line
      curStr = strtrim(strtok(curStr, delimComment));  
      
      % Check for model name tag
      if strncmp(curStr,delimModelName,length(delimModelName))
         curStr = strrep(curStr, delimModelName, '');
         curStr = removeCharsFromString(curStr, whiteSpace);
         modelNameStr = curStr;
         continue
      end
      % Check for species tag
      if strncmp(curStr,delimSpecies,length(delimSpecies))
         curStr = strrep(curStr, delimSpecies, '');
         curStr = removeCharsFromString(curStr, whiteSpace);
         species = addToCellString(species, curStr);
         continue  
      end
      % Check for parameter tag
      if strncmp(curStr,delimParameter,length(delimParameter))
         curStr = strrep(curStr, delimParameter, '');
         curStr = removeCharsFromString(curStr, whiteSpace);
         parameters = addToCellString(parameters, curStr);
         continue  
      end

      % Check for reaction tag
      if strncmp(curStr,delimReaction,length(delimReaction))
         curStr = strrep(curStr, delimReaction, '');
         % break up current string curStr in parts
         %#ok<*STTOK> strtok is much older (more compatible) than the new split() function
         [nameStr,   curStr] = strtok(curStr, delimParts);  % name of reaction
         [rateStr,   curStr] = strtok(curStr, delimParts);  % rate of reaction
         [modStr,    curStr] = strtok(curStr, delimParts);  % modifier
         [eductStr,  curStr] = strtok(curStr, delimParts);  % educts string
         [productStr,curStr] = strtok(curStr, delimParts);  % products string
         % check if there are leftovers, then warn
         if ~isempty(curStr)
            fprintf('WARNING: Leftover in line %03g found: |%s|\n', lineNum, curStr);
         end
         % process strings
         nameStr = strtrim(nameStr);
         modStr = strtrim(modStr);
         eductStr   = removeCharsFromString(eductStr  ,whiteSpace);  
         productStr = removeCharsFromString(productStr,whiteSpace);
         rateStr    = removeCharsFromString(rateStr   ,whiteSpace);
         % process educts
         eductnames={};
         eductfactors={};
         while ~isempty(eductStr)
            [reactant, eductStr] = strtok(eductStr, delimReactants);
            [factorStr, reactant] = strtok(reactant, delimFactors);
            reactant = strtok(reactant, delimFactors);
            factor = str2double(factorStr);
            if isempty(factor), reactant = factorStr; factor = 1; end  % if no factor was given
            if isempty(reactant), continue; end
            eductnames{end+1}  = reactant; %#ok<AGROW> - we don't know the number of educts here
            eductfactors{end+1}= factor;   %#ok<AGROW> - since we are still processing the file
            species = addToCellString(species, reactant);
         end
         % process products
         productnames={};
         productfactors={};
         while ~isempty(productStr)
            [reactant, productStr] = strtok(productStr, delimReactants);
            [factorStr, reactant] = strtok(reactant, delimFactors);
            reactant = strtok(reactant, delimFactors);
            factor = str2double(factorStr);
            if isempty(factor),  reactant = factorStr; factor = 1; end  % if no factor was given
            if isempty(reactant), continue; end
            productnames{end+1}  = reactant; %#ok<AGROW> - we don't know the number of products here
            productfactors{end+1}= factor;   %#ok<AGROW> - since we are still processing the file
            species = addToCellString(species, reactant);
         end
         % set up reaction
         reacNum = reacNum + 1;
         reactions(reacNum) = createReaction(nameStr, eductnames, eductfactors, productnames, ...
                                             productfactors, rateStr, modStr);   %#ok<AGROW>
      end % end of reaction processing
   
   end
   
   model = createModel(modelNameStr, reactions, species, parameters);
   
end


   
   