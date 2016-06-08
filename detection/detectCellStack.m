function [cellDetections, maskStackOne, maskStackTwo] = detectCellStack( imageStack, ... 
    intensityThreshold, distanceThreshold )
%% distanceThreshold - usually 3, intensityThreshold - varies (.3)
%%
% intensityThreshold domain: [0,1]
[rows,cols,T] = size(imageStack);

%% Obtain initial detections
for t=1:T
    cellDetections{t,1} = sortDetections(detectCells(imageStack(:,:,t),1)); % radius 1
    cellDetections{t,2} = sortDetections(detectCells(imageStack(:,:,t),2)); % radius 2
end

%% Threshold detections (whose intensities are too small)
for t=1:T
    for i=1:2
        tmp = find(cellDetections{t,i}(:,3) >= intensityThreshold);
        cellDetections{t,i} = cellDetections{t,i}(tmp,:);
    end
end

%% Remove detections (that are out of bounds)
for t=1:T
    for i=1:2
        cellDetections{t,i} = removeDetections(cellDetections{t,i},rows,cols);
    end
end


%% Merge detections (that are too close)
for t=1:T
    for i=1:2
        cellDetections{t,i} = mergeDetections(cellDetections{t,i},distanceThreshold);
    end
end

%% Create mask with detections (using scale of radius 2)
maskStackTwo = zeros(size(imageStack));
for t=1:T
    N = size(cellDetections{t,2},1);
    for n=1:N % makes crosshair at each detection
        maskStackTwo(cellDetections{t,2}(n,2),cellDetections{t,2}(n,1),t) = 1;
        maskStackTwo(cellDetections{t,2}(n,2),cellDetections{t,2}(n,1)+1,t) = 1;
        maskStackTwo(cellDetections{t,2}(n,2),cellDetections{t,2}(n,1)-1,t) = 1;
        maskStackTwo(cellDetections{t,2}(n,2)+1,cellDetections{t,2}(n,1),t) = 1;
        maskStackTwo(cellDetections{t,2}(n,2)-1,cellDetections{t,2}(n,1),t) = 1;
    end
end

%% Create mask with detections (using scale of radius 1)
maskStackOne = zeros(size(imageStack));
for t=1:T
    N = size(cellDetections{t,1},1);
    for n=1:N % makes crosshair at each detection
        maskStackOne(cellDetections{t,1}(n,2),cellDetections{t,1}(n,1),t) = 1;
        maskStackOne(cellDetections{t,1}(n,2),cellDetections{t,1}(n,1)+1,t) = 1;
        maskStackOne(cellDetections{t,1}(n,2),cellDetections{t,1}(n,1)-1,t) = 1;
        maskStackOne(cellDetections{t,1}(n,2)+1,cellDetections{t,1}(n,1),t) = 1;
        maskStackOne(cellDetections{t,1}(n,2)-1,cellDetections{t,1}(n,1),t) = 1;
    end
end

end

