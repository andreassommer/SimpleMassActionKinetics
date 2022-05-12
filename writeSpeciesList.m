function writeSpeciesList(model)
   % function writeSpeciesList(model)
   %
   % Writes Matlab-File that returns a species-List of the given Model.
   %
   % The generated file has the name "speciesList_%modelname%",
   % where modelname is retrieved from the given model.
   %
   
   speciesFunctionName = sprintf('speciesList_%s', model.name);
   speciesListFile = [speciesFunctionName '.m'];
   
   % Öffne Ausgabedatei
   fid = fopen(speciesListFile,'w');
   
   % Schreibe Funktionskopf und Listenanfang
   fprintf(fid, 'function list = %s() \n',speciesFunctionName);
   fprintf(fid, '   list = {  ...     \n');
      
   % Schreibe Speziesliste
   maxlength = max(cellfun(@length, model.species)) + 3;
   for k = 1:length(model.species)
      curSpec = model.species{k};
      formatstring = sprintf('      ''%%s'' %s , ...  %%%% %%02d ',blanks(maxlength-length(curSpec)));
      if (k==length(model.species)), formatstring = replaceInString(formatstring,',',' '); end;
      fprintf(fid, [formatstring '\n'], curSpec, k);
   end
   
   % Schreibe Listenende und Funktionsende
   fprintf(fid, '   }; \n');
   fprintf(fid, 'end   %% end of function %s \n',speciesFunctionName);
   
   % Schließe Ausgabedatei
   fclose(fid);
   
end