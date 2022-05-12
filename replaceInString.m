function newStr = replaceInString(str, remStr, repStr)
   % function newStr = replaceInString(str, remStr, repStr);
   %
   % Replaces strings in cell string array.
   %
   % INPUT:       str  -  cell array of strings   (strings to be processed)
   %           remStr  -  cell array of strings   (strings to be replaced)
   %           repStr  -  cell array of strings   (new strings)
   %
   % OUTPUT:   newStr  -  cell array of strings   (processed strings)
   %
   % Note: repStr may be a single string, meaning that any of the strings
   %       in remStr will be replaced by that string
   %
   %
   % Copyright (c) 2009, Andreas Sommer
   % andreas.sommer@iwr.uni-heidelberg.de
   % mail@andreas-sommer.eu
   
   % [andreas.sommer@iwr.uni-heidelberg.de - 25.05.2009]
   
   % variable containing new string
   newStr = str;
   
   % input must be cell arrays
   if ~iscellstr(newStr),  newStr = {newStr};   end
   if ~iscellstr(remStr),  remStr = {remStr};   end
   if ~iscellstr(repStr),  repStr = {repStr};   end
   
   % single string in repStr?
   if (length(repStr)==1)
      string = repStr{1};
      for k = 1:length(remStr),   repStr{k} = string;    end
   end
   
   % little error check
   if ~(length(remStr)==length(repStr)),  error('ERROR: remStr and repStr must be cell string arrays of same length'); end
      
   % process strings
   for strLine = 1:length(newStr);
      for k = 1:length(remStr);
         newStr{strLine} = strrep(newStr{strLine}, remStr{k}, repStr{k});
      end
   end
   
   % if input was a single string, return a single string (not a cell string of length 1)
   if ~iscellstr(str),
      newStr = newStr{1};
   end
   
   
end
