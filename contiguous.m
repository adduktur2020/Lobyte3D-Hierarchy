function contiguousThickness=contiguous(depos,glob)
%looks for how long deposition remains in one location before switching

minThickness=0; %minimum thickness to consider it a layer

contiguousThickness=NaN(glob.ySize,glob.xSize,glob.totalIterations); %preallocate memory

for x=1:glob.xSize
    for y=1:glob.ySize
        contiguousLayersCount=0; % number of contiguous layers
        for t=2:glob.totalIterations
            if depos.transThickness(y,x,t)>minThickness % if there has been deposition
                contiguousLayersCount=contiguousLayersCount+1; %add to number of uninterupted depositions
            else
                contiguousThickness(x,y,t)=contiguousLayersCount; %save the number of depositions
                contiguousLayersCount=0; %and then reset the number to zero   
            end
        end
    end
end

maxContiguousThickness=max(contiguousThickness,[],3);
meanContiguousThickness=mean(contiguousThickness,3,'omitnan');

figure
subplot(1,2,1)
imagesc(maxContiguousThickness)
colorbar
title('Maximum contiguous deposition')
axis equal

subplot(1,2,2)
imagesc(meanContiguousThickness)
colorbar
title('Mean contiguous deposition')
axis equal


end %function