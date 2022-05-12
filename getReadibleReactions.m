function reactionStrings = getReadibleReactions(model)
   % function getReadibleReactions(model)
   % 
   % Returns reactions in a (hopefully) readible format
   %
   % INPUT:    model           - model 
   % OUTPUT:   reactionstrings - cell array of readible reactions
   error('NOT WORKING: NO Modifiers are incorporated!')
   reactions = model.reactions;
   reacCount = length(reactions);
   reactionNames = cell(reacCount,1);
   leftSides = cell(reacCount,1);
   rightSides = cell(reacCount,1);
   reactionStrings = cell(reacCount,1);
   
   % cycle through reactions
   for reacNum = 1:reacCount

      % init
      currentReaction = reactions(reacNum);
      
      % set up reaction names
      reactionNames{reacNum} = currentReaction.name;

      % set up left sides (educts)
      displayString = '';
      count = length(currentReaction.educts.names);
      for j = 1:count
          displayString = [ displayString  num2str(currentReaction.educts.factors{j})  '*'  currentReaction.educts.names{j} ];
          if (j < count),
             displayString = [ displayString '  +  '];
          end
      end
      displayString = strrep(displayString, '1*', '');         % remove factor 1       
      leftSides{reacNum} = displayString;

      % set up right side (products)
      displayString = '';
      count = length(currentReaction.products.names);
      for j = 1:count
          displayString = [ displayString  num2str(currentReaction.products.factors{j})  '*'  currentReaction.products.names{j} ]; %#ok<AGROW>
          if (j < count),
             displayString = [ displayString '  +  '];
          end
      end
      displayString = strrep(displayString, '1*', '');         % remove factor 1 
      rightSides{reacNum} = displayString;
      
   end
   
   % determine sizes for adjustments 
   maxLengthReactionName = max(cellfun(@length, reactionNames));
   maxLengthLeftSides    = max(cellfun(@length, leftSides));
   %maxLengthRightSides   = max(cellfun(@length, rightSides));
   
   % setup reaction strings (ReactionName:  ed1 + ed2 + ... + edn  ==> prod1 + prod2 + ... + prodn)     --->  Adjusted at ':' and '==>';
   for reacNum = 1:reacCount
      currentName = reactionNames{reacNum};
      currentName = currentName(1:min(maxLengthReactionName,length(currentName)));
      currentName = [blanks(maxLengthReactionName-length(currentName)) currentName];
      currentLeft = leftSides{reacNum};
      currentLeft = [blanks(maxLengthLeftSides-length(currentLeft)) currentLeft];
      currentRight= rightSides{reacNum};
      reactionStrings{reacNum} = sprintf('%s:     %s   ==>   %s', currentName, currentLeft, currentRight);
   end
   
end