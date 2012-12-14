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

        function [normalMat] = normalizeByColumn(mat, vec)
        
            for i=1:size(mat, 2)
                normalMat(:, i) = mat(:, i)/vec(i);
            end

        end
        function run(NthMeetupBinsPerMember, uniqueEventIds)
            niles = [1, 2, 4, 8];
            for i=niles
                Workspace.plotOrderedRollUpNthMeetupBinsPerMember(NthMeetupBinsPerMember, i, 24, uniqueEventIds);
            end
            
        end
        function plotOrderedRollUpNthMeetupBinsPerMember(NthMeetupBinsPerMember, rollUps, cycleCount, uniqueEventIds)
            
            attendances = [];
            NthMeetupBinsPerMemberSorted(1:cycleCount, 1:cycleCount, 1:size(uniqueEventIds, 2)) = 0;
            
            for i=1:size(NthMeetupBinsPerMember, 1)
               attendances(i) =  sum(sum(squeeze(NthMeetupBinsPerMember(i, :, :))));
            end
            
            [attSort, attOrder] = sort(attendances, 'descend');
            size1 = 0;
            
            for i=1:size(NthMeetupBinsPerMember, 1)
                NthMeetupBinsPerMemberSorted(i, :, :) = NthMeetupBinsPerMember(attOrder(i), :, :);
                size1 = size1 + sum(sum(NthMeetupBinsPerMemberSorted(i, :, :)));
                
                %fprintf('%d %d\n', sum(sum((NthMeetupBinsPerMember(attOrder(i), :, :) ))), sum(sum((NthMeetupBinsPerMemberSorted(i, :, :)))));
            end
            
            perRollUpInt = floor(size(NthMeetupBinsPerMember, 1)/rollUps);
            
            perRollUp = size(NthMeetupBinsPerMember, 1)/rollUps;
            
            if(perRollUp - perRollUpInt ~= 0.0)
                
                perRollUpInt = perRollUpInt + 1;
                
            end
            size2 = 0;
            sizes(1:rollUps) = 0;
            perRollUps(1:rollUps) = 0;
            counter = 1;
            sizecount = 0;
            tsize = 0;
            
            for i=1:size(NthMeetupBinsPerMemberSorted, 1)
                
               tsize = tsize + sum(sum(NthMeetupBinsPerMemberSorted(i, :, :)));
               size2 = size2 + sum(sum(NthMeetupBinsPerMemberSorted(i, :, :))); 
               sizecount = sizecount + 1;
               
               if(size2 >= ceil(size1/rollUps))
                   perRollUps(counter) = sizecount;
                   
                   sizes(counter) = size2;
                   sizecount = 0;
                   size2 = 0;
                   
                   counter = counter + 1;
               end
            end
            
            if(perRollUps(end) == 0)
               perRollUps(end) = sizecount; 
               sizes(end) = size2;
            end
            
            
            
            
            NthMeetupBinsPerMemberSortedRolled(1:rollUps, 1:cycleCount, 1:size(uniqueEventIds, 2)) = 0;
            count = 0;
            test(1:rollUps, 1:size(uniqueEventIds, 2)) = 0;
            normVec(1:rollUps, 1:cycleCount) = 0;
            for i=1:rollUps
                
               %fprintf('%d %d\n', i, count);
                
               for j=1:perRollUps(i)
                   
                   count = count + 1;
                   
                   if(count <= size(NthMeetupBinsPerMember, 1))
                       %fprintf('  %d %d\n', sum(sum(NthMeetupBinsPerMemberSortedRolled(i, :, :))), sum(sum(NthMeetupBinsPerMemberSorted(count, :, :))));
                       test(i, :) = test(i, :) + squeeze(sum(NthMeetupBinsPerMemberSorted(count, :, :)))';
                       NthMeetupBinsPerMemberSortedRolled(i, :, :) = NthMeetupBinsPerMemberSortedRolled(i, :, :) + NthMeetupBinsPerMemberSorted(count, :, :);
                       normVec(i, :) = normVec(i, :) + sum(squeeze(NthMeetupBinsPerMemberSortedRolled(i, :, :))');
                   end
               end
               
                
            end
            
            for i=1:rollUps
               %fprintf('%d\n', sum(test(i, :))); 
            end
            
            for i=1:size(NthMeetupBinsPerMemberSortedRolled, 1)
                
                figure('Visible','off');
                vizMat = squeeze(NthMeetupBinsPerMemberSortedRolled(i, :, :))';
                %vec = sum(vizMat);
                %flipud( squeeze(
                %vizMat = Workspace.normalizeByColumn(vizMat, vec);
                imagesc(vizMat);
                colormap(hot);
                set(gca, 'YDir', 'normal');
                
                fileStr = strcat(sprintf('out_%d_%d', i, rollUps));
                titleStr = sprintf('First Attendance Density for Descending Total Attendance %d-Quantile %d of %d', rollUps, i, rollUps);
                title(titleStr);
                xlabel('Invitation Acceptance Hour of the Day');
                ylabel('Event Index (Higher is Later)');
                
                h=gcf;
                set(h,'PaperOrientation','landscape');
                set(h,'PaperUnits','normalized');
                set(h,'PaperPosition', [0 0 1 1]);
                
                print(gcf, strcat('out/png/', fileStr, '.png'), '-dpng','-r100');
                print(gcf, '-dpdf', '-r600', strcat('out/pdf/', fileStr, '.pdf'));
                saveas(gcf, strcat('out/fig/',fileStr, '.fig'));
                
                set(gcf,'nextplot','new');
            end

        end
        
        %returns n-th attendence invitation reply time bin (and per member)
        function [NthMeetupBins, NthMeetupBinsPerMember] = getNthMeetupBins(cycleCount, binTime, createdMilli, timeOffset, memberIds, eventIds, uniqueEventIds, uniqueMemberIds)
            NthMeetupBins(1:cycleCount, 1:size(uniqueEventIds, 2)) = 0;
            NthMeetupBinsPerMember(1:size(uniqueMemberIds, 2), 1:cycleCount, 1:size(uniqueEventIds, 2)) = 0;
            
            
            n = 1;
            m = 0;
            uniqueEvents = [];
            uniqueMembers = [];
            memberCount(1:size(uniqueMemberIds, 2)) = 0;
            
            for i=1:size(eventIds, 1)
                %fprintf('memberId: %d', memberIds);
                if(~ismember(memberIds(i), uniqueMembers))
                    
                    %fprintf(' is unique\n');
                    
                    uniqueMembers(end + 1) = memberIds(i);
                    
                else
              
                end
                
                if(~ismember(eventIds(i), uniqueEventIds))
                   uniqueEvents(end + 1) = eventIds(i); 
                else
                    
                end
                
                m = find(uniqueMembers == memberIds(i));
                memberCount(m) = memberCount(m) + 1;
                n = memberCount(m);
                
                bin =  Workspace.getBin(createdMilli(i), timeOffset, binTime, cycleCount);
                
                fprintf('%d %d %d\n', n, m, bin);
                if( n == 18)
                   i = 4; 
                end
                NthMeetupBins(bin, n) = NthMeetupBins(bin, n) + 1;
                NthMeetupBinsPerMember(m, bin, n) = NthMeetupBinsPerMember(m, bin, n) + 1;
                
                
                n = n + 1;
                
            end
            
            
        end
        
        function [binMat] = binById(cycleCount, binTime, timesMilli, timeOffset, ids, uniqueIds)
           
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
                
                bins = Workspace.binData(cycleCount, binTime, timeVec', timeOffset);
                binMat(:, a) = bins';
                
                  
            end
            if(size(uniqueIds, 1) ~= size(uniques, 2))
                   fprintf('mismatch\n'); 
            end
            
        end
        
        function [bin] = getBin(time, timeOffset, binTime, cycleCount)
            bin = mod(time - timeOffset, cycleCount*binTime);
            bin = ceil(bin/binTime);
        end
        
        function [bins] = binData(cycleCount, binTime, timesMilli, timeOffset)
           
            %timeOffset = 14400000;  %GMT-4
            %width = cycleCount * binTime;
            bins(1:cycleCount) = 0;
            
            for i=1:size(timesMilli, 1)
               %a = mod(timesMilli(i) - timeOffset , width);
               %a = ceil(a/binTime);
               a = Workspace.getBin(timesMilli(i), timeOffset, binTime, cycleCount);
               if(a == 0)
                  disp('why'); 
               end
               
               bins(a) = bins(a) + 1;
               %fprintf('%d\n', a);
            end
            
            
        end
        
    end
    
end

