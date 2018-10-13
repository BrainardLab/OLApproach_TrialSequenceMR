function score = calcTaskAccuracy(responseStruct,block)

totalEvents = 0;
tally = 0;
for ii =  1:length(block)
    if block(ii).attentionTask.segmentFlag
        totalEvents = totalEvents +1;
    end
    
    if ~isempty(responseStruct.events(ii).buffer)
        blockResp =  ~isempty(find(responseStruct.events(ii).buffer.keyCode ~= 18));
    else
        blockResp = 0;
    end
        
    if block(ii).attentionTask.segmentFlag & blockResp
        tally = tally +1;
    end
end

score = tally/totalEvents;

end