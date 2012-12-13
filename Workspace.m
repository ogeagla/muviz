classdef Workspace
    %WORKSPACE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Static)
        
        function [uniqueIds] = getUniqueIds(ids)
           
            uniqueIds = [];
            
            for i=1:size(ids, 1)
                if(~ismember(ids(i), uniqueIds)) 
                   uniqueIds(end + 1) = ids(i); 
                end
            end
            
        end
        
        function [binMat] = binById(cycleCount, binTime, timesMilli, ids, uniqueIds)
           
            binMat(1:cycleCount, 1:size(uniqueIds, 2)) = 0;
            
            uniques = [];
            
            for i=1:size(timesMilli, 1)
                
                timeVec = [];
                
                if(ismember(ids(i), uniques))
                    %a = find(uniques == eventIds(i));
                    continue;
                else
                    a = size(uniques, 2) + 1;
                    uniques(a) = ids(i);
                    timeVecSize = 1;
                    for j=i:size(timesMilli, 1)
                        if(ids(j) == uniques(a))
                           timeVec(timeVecSize) = timesMilli(j);
                           timeVecSize = timeVecSize + 1;
                        end
                    end
                end
                
                bins = Workspace.binData(cycleCount, binTime, timeVec');
                binMat(:, a) = bins';
            end
            if(size(uniqueIds, 1) ~= size(uniques, 2))
                   fprintf('mismatch\n'); 
            end
            
        end
        
        function [bins] = binData(cycleCount, binTime, timesMilli)
           
            timeOffset = 14400000;  %GMT-4
            width = cycleCount * binTime;
            bins(1:cycleCount) = 0;
            
            for i=1:size(timesMilli, 1)
               a = mod(timesMilli(i) - timeOffset , width);
               a = ceil(a/binTime);
               
               if(a == 0)
                  disp('why'); 
               end
               
               bins(a) = bins(a) + 1;
               fprintf('%d\n', a);
            end
            
            
        end
        
    end
    
end

