function h = setPlotGrid2(fid,xPlot,yPlot,nCols,nPlots,margin,border)
%% h=SetPlotGrid(xPlot,yPlot,nCols,nPlots,margin,border)
% Margin sets left, right, top, and bottom border of the figure window
% Border sets left, ritht, top, and bottom borders of the individual
% plots.

%figure('Position',[0, 0, xPlot, yPlot]);
figure(fid); clf;
nRows = ceil(nPlots/nCols);

count = 0;
for i=1:nRows
  for j=1:nCols
    count = count + 1;
    if (count<=nPlots)
      h(count) = subplot(nRows,nCols,count);
    end
  end
end

bl = margin(1);
br = margin(2);
bt = margin(3);
bb = margin(4);

c = 0;
x0=0:1/nCols:1-1/nCols;
y0=flip(0:1/nRows:1-1/nRows);
dl = border(1);
dr = border(2);
dt = border(3);
db = border(4);
for i=1:nRows
  for j=1:nCols
    c = c + 1;
    if (c<=nPlots)
h(c).Position(1) = bl+(j-1)*(1-bl-br)/nCols + dl*(1-bl-br)/nCols;
h(c).Position(3) = (1-bl-br)/nCols*(1-dl-dr);
h(c).Position(2) = bb+(nRows-i)*(1-bt-bb)/nRows + db*(1-bl-br)/nRows;
h(c).Position(4) = (1-bt-bb)/nRows*(1-dt-db);
    end
  end
end

%h(7).Position(3) = h(7).Position(3)*2 + (1-bl-br)/nCols*(dl + dr);
%h(7).Position(3) = bl;
%h(8).Visible = 'off';







