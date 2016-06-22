function convert_cluster2track(eidx)


% cluster path
clusterPath = ['/BS/joint-multicut/work/Tracking_result/EXP_idx_' num2str(eidx) '/'];
%% load label
label = dir(clusterPath);
label = label(~ismember({label.name},{'.','..'}));
disp('converting cluster to tracks...');
%% loop sequence
for i=1:size(label,1)
    try
    load([clusterPath label(i).name '/clusters.mat']);
    load([clusterPath label(i).name '/optimization_result.mat']);
    num_frames = size(EXP.U,1);
    num_cluster = length(clusters);
    track = cell(1,num_cluster);
    track_frames =cell(1,num_cluster);
    % loop clusters
    for c=1:num_cluster
        cur_cluster = clusters{c};
        cur_cluster_frames = cluster_frames{c};
        track_frames{1,c} = (min(cur_cluster_frames):max(cur_cluster_frames))';
        % track{} = [x1 y1 x2 y2 score frame]
        track{1,c} = zeros(max(cur_cluster_frames)-min(cur_cluster_frames)+1,6);
        jumplist = [];
        % loop frames in cluster
        for f_ind=min(cur_cluster_frames):max(cur_cluster_frames)
            list = find(cur_cluster_frames==f_ind);
            % box exists in the frame
            if size(list,1)>0
                f_box = cur_cluster(list,:);
                [~,I] = sort(f_box(:,5),'descend');
                cur_box = f_box(I(1,1),:);
                track{1,c}(f_ind-min(cur_cluster_frames)+1,1:5) = cur_box;
                track{1,c}(f_ind-min(cur_cluster_frames)+1,6) = f_ind;
            % no box in the frame
            else
                jumplist(end+1) = f_ind;
            end
        end
        % smooth
        no_empty = track{1,c};
        no_empty(all(no_empty==0,2),:)=[];
        no_empty(:,1) = smooth(no_empty(:,1),'rlowess');
        no_empty(:,2) = smooth(no_empty(:,2),'rlowess');
        no_empty(:,3) = smooth(no_empty(:,3),'rlowess');
        no_empty(:,4) = smooth(no_empty(:,4),'rlowess');
        % fill
        if size(jumplist,2)>0
            fill_empty = zeros(size(jumplist,2),6);
            fill_empty(:,1) = interp1(no_empty(:,6)',no_empty(:,1)',jumplist,'spline');
            fill_empty(:,2) = interp1(no_empty(:,6)',no_empty(:,2)',jumplist,'spline');
            fill_empty(:,3) = interp1(no_empty(:,6)',no_empty(:,3)',jumplist,'spline');
            fill_empty(:,4) = interp1(no_empty(:,6)',no_empty(:,4)',jumplist,'spline');
            fill_empty(:,6) = jumplist;
            [~,sInd] = sort([no_empty(:,6);fill_empty(:,6)],'ascend');
            track{1,c} = [no_empty;fill_empty];
            track{1,c} = track{1,c}(sInd,:);
        else
            track{1,c} = no_empty;
        end
    end
    stateInfo = convert_tracks2stateInfo(track,track_frames);
    save([clusterPath label(i).name '/track.mat'],'track','track_frames','stateInfo');
    catch
    end
end

end