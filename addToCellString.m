function newStr = addToCellString(cellStr, addStr)
   % newStr = addToCellString(cellStr, str)
   %
   % Adds strings in addStr to cell array cellStr if not already present.
   % In contrast to Matlab's built-in function union, the result is not sorted.
   %
   % INPUT:       cellStr  -  cell array of strings   (string list to be extended)
   %               addStr  -  cell array of strings   (strings to be added)
   %
   % OUTPUT:       newStr  -  cell array of strings   (combined string list)
   %
   % Copyright (c) 2009,2010,2011, Andreas Sommer
   % andreas.sommer@iwr.uni-heidelberg.de
   % mail@andreas-sommer.eu

   % [andreas.sommer@iwr.uni-heidelberg.de - 25.05.2009]
   
   newStr = cellStr;
   if isempty(addStr),         return;                   end
   if ~iscellstr(addStr),      addStr = {addStr};        end
   if isempty(cellStr),        newStr = addStr; return;  end
   for k = 1:length(addStr)
      if ismember(addStr(k), cellStr)
         continue
      else
         newStr(end+1) = addStr(k);
      end
   end
end
