function Ca_new=Ca_sol_fix_negative(Ca)
% Fix problem of negative Ca solution values whilst maintaining mass
% balance.

Ca_new = Ca;
ii = find(Ca < -1e-10);
if (~isempty(ii))
  for i=1:length(ii)
    if ii(i)>1
      Ca_new(ii(i)-1) = Ca(ii(i)-1) + Ca(ii(i));
      Ca_new(ii(i)) = 0;
      if (Ca_new(ii(i)-1) < 0) && (ii(i)<length(Ca))
        Ca_new(ii(i)+1) = max(0,Ca(ii(i)+1) + Ca_new(ii(i)-1));
        Ca_new(ii(i)-1) = 0;
      end
    end
  end
end
Ca_new = max(0,Ca_new);

%figure(2)
%plot(Ca,1:length(Ca),Ca_new,1:length(Ca));
%legend({'old','new'});
%grid
