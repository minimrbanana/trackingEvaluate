function stateInfo = convert_tracks2stateInfo(track,track_frames)




stateInfo = repmat(struct('Xi',[],'Yi',[],'W',[],'H',[] ), 1, 1);
num_frame = max(cellfun(@max,track_frames));
stateInfo.Xi = zeros(num_frame,1);
stateInfo.Yi = zeros(num_frame,1);
stateInfo.W = zeros(num_frame,1);
stateInfo.H = zeros(num_frame,1);
stateInfo.S = zeros(num_frame,1);
for i =1 : size(track,2)
    tracklet = track{i};
    tracklet_firstidx = tracklet(1,6);
    tracklet_score = tracklet(:,5);
    
    for n = 1: size(tracklet,1)
        frame_idx = tracklet_firstidx + n - 1;
        if frame_idx <= num_frame
            stateInfo.Xi(frame_idx,i) = (tracklet(n,1) + tracklet(n,3))/2;
            stateInfo.Yi(frame_idx,i) = tracklet(n,4);
            stateInfo.H(frame_idx,i) = tracklet(n,4) - tracklet(n,2);
            stateInfo.W(frame_idx,i) = tracklet(n,3) - tracklet(n,1);
            stateInfo.S(frame_idx,i) = tracklet_score(n);
        end
    end
    
end
end