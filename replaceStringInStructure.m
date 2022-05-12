function newStruct = replaceStringInStructure(structure, searchStr, repStr, varargin)
   % function newStruct = replaceStringInStructure(structure, searchStr, repStr  [, 'skipfields', fields] )
   %
   % Replaces each occurence of searchStr in structure with repStr.
   % Walks recursively through the fields of structure.
   %
   % INPUT:    structure   - struct  or  struct array
   %           searchStr   - cellstr  (search strings to be replaced)
   %           repStr      - cellstr  (new strings, same length as searchStr)
   %
   % OUPUT:    newStruct   - new structure with replaced strings
   %
   % Copyright (c) 2009,2010,2011, Andreas Sommer
   % andreas.sommer@iwr.uni-heidelberg.de
   % mail@andreas-sommer.eu
   
   if ~iscell(searchStr),  searchStr = {searchStr};  end;
   if ~iscell(repStr),     repStr = {repStr};        end;

   % little error check
   if ~(length(searchStr)==length(repStr)),
      disp('WARNING: Cellstrings not of same length. Nothing replaced!')
      return;
   end

   % check additional arguments
   skipfields = '';
   if ~isempty(varargin)
      % lowercase all directive strings
      varargin(1:2:end) = lower(varargin(1:2:end));
      if ismember('skipfields', varargin)
         position = find(ismember('skipfields', varargin));
         skipfields = varargin{position+1};
         if ~iscell(skipfields), skipfields = cellstr(skipfields); end;
      end
   end
   
   % sort strings by decreasing length to avoid matching "ABCD" to "ABCDEF"
   lengths = cellfun('length',searchStr);
   [lengths, sortIDX] = sort(lengths, 'descend');
   searchStr = searchStr(sortIDX);
   repStr = repStr(sortIDX);
   
   % walk through fields of structure
   for index = 1:length(structure)
      fields = fieldnames(structure(index));
      for k = 1:length(fields)
         field = fields{k};
         % skip specified fields
         if ismember(fields(k), skipfields)
            continue
         end
         % recursive walkthrough
         if isstruct(structure(index).(field))
            structure(index).(field) = replaceStringInStructure(structure(index).(field), searchStr, repStr, varargin{:});
            continue
         end
         % replace strings
         if (ischar(structure(index).(field)) || iscellstr(structure(index).(field)));
            for j = 1:length(searchStr)
               structure(index).(field) = strrep(structure(index).(field),searchStr{j},repStr{j});
            end
         end
      end
   end
   newStruct = structure;

end
