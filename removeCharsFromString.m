function newStr = removeCharsFromString(orgStr, chars)
   % function newStr = removeCharsFromString(orgStr, chars);
   %
   % Removes any characters from chars in orgstr.
   %
   % INPUT:       orgStr - string or cellstring   (string to be processed)
   %              chars  - string                 (characters to be removed)
   %
   % OUTPUT:      newStr - string or cellstring   (orgstr with chars removed)
   %
   % Author: Andreas Sommer, 2009,2010,2011
   % andreas.sommer@iwr.uni-heidelberg.de
   % mail@andreas-sommer.eu
   
   % do nothing if not a string
   if (~ischar(orgStr) && ~iscellstr(orgStr))
      newStr = orgStr;
      return
   end;
   
   % change to cell string
   orgStr = cellstr(orgStr);
   newStr = orgStr;
   
   % remove characters 
   for strNum = 1:length(orgStr);
      for charNum = 1:length(chars);
         newStr{strNum} = strrep(newStr{strNum},chars(charNum),'');
      end
   end
   
   % return string
   if (length(newStr) == 1)
      newStr = newStr{1};
   end
   
end
