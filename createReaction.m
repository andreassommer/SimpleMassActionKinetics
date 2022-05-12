function reaction = createReaction(reactionname, eductnames, eductfactors, productnames, productfactors, rate, modifier)
   % function reaction = createReaction(reactionname, eductnames, eductfactors, productnames, productfactors, rate, modifier)
   %
   % Create reaction structure from given reaction parameters
   %
   % INPUT:    reactionname   - string (name of this reaction)
   %           eductnames     - cell array of strings
   %           eductfactors   - cell array of integers (may be empty, then set to 1 each)
   %           productnames   - cell array of strings
   %           productfactors - cell array of integers (may be empty, then set to 1 each)
   %           rate           - string
   %           modifier       - string
   %
   % OUTPUT:   reaction       - reaction structure
   %
   if isempty(eductfactors),      eductfactors   = num2cell(ones(length(eductnames),1));     end
   if isempty(productfactors),    productfactors = num2cell(ones(length(productnames),1));   end
   if ~exist('modifier','var'),   modifier = '';                                             end
   if ~iscell(eductnames),        eductnames = {eductnames};                                 end
   if ~iscell(eductfactors),      eductfactors = num2cell(eductfactors);                     end
   if ~iscell(productnames),      productnames = {productnames};                             end
   if ~iscell(productfactors),    productfactors = num2cell(productfactors);                 end
   reaction.name             = reactionname;
   reaction.educts.names     = eductnames;
   reaction.educts.factors   = eductfactors;
   reaction.products.names   = productnames;
   reaction.products.factors = productfactors;
   reaction.rate             = rate;
   reaction.modifier         = modifier;
end