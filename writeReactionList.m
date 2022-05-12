function writeReactionList(model)
   % function writeReactionList(model)
   %
   % Writes Matlab-File that returns a reaction list of the given model.
   %
   % The generated file has the name "reactionList_%modelname%",
   % where modelname is retrieved from the given model.
   %
   
   reactionFunctionName = sprintf('reactionList_%s', model.name);
   reactionListFile = [reactionFunctionName '.m'];
   
   % Öffne Ausgabedatei
   fid = fopen(reactionListFile,'w');
   
   % Schreibe Funktionskopf und Listenanfang
   fprintf(fid, 'function list = %s() \n',reactionFunctionName);
   fprintf(fid, '   %% Automatically generated by writeReactionList \n');
   fprintf(fid, '   list = {  ...     \n');
      
   % Schreibe Speziesliste
   reactionnames = {model.reactions.name};
   maxlength = max(cellfun(@length, reactionnames)) + 3;
   for k = 1:length(reactionnames)
      curSpec = reactionnames{k};
      formatstring = sprintf('      ''%%s'' %s , ...  %%%% %%02d ',blanks(maxlength-length(curSpec)));
      if (k==length(reactionnames)), formatstring = replaceInString(formatstring,',',' '); end;
      fprintf(fid, [formatstring '\n'], curSpec, k);
   end
   
   % Schreibe Listenende und Funktionsende
   fprintf(fid, '   }; \n');
   fprintf(fid, 'end   %% end of function %s \n',reactionFunctionName);
   
   % Schließe Ausgabedatei
   fclose(fid);
   
end