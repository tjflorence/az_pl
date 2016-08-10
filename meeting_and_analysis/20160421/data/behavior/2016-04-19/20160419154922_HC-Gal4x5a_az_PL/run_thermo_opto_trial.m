function expi = run_thermo_opto_trial(expi, app)

global expr
global appr
global timer1
global binvals
global init

expr = expi;
appr = app;
%% bin vals
[init, patternStruct, binvals] = makePatternStructSBD;
    
%% connect to camera, usb serial mode
COMport = 'COM9';
%Connect to serial object
%Open serial port interface
%__________________________________________________________________
s=serial(COMport);%<------------------------------------------------COM PORT DEFINITION
%------------------------------------------------------------------
s.baudrate=1250000;
s.bytesavailablefcn={@baf}; %function called whenever data is available
s.bytesavailablefcncount=48000/expr.settings.hz; %12 bytes per sample, 4kSamples/sec = 48000 bytes per second.  20Hz=2400
s.bytesavailablefcnmode='byte';
s.inputbuffersize=50000;
fopen(s);
%Default to Vf,Vs,Om mode
fwrite(s,[246,0])
% removes any data from buffer
if s.bytesavailable>0
     fread(s,s.bytesavailable); 
end

expr.c_trial.data.end_trial = 0;

%starts logging
disp('beginning trial')

appr.ao.outputSingleScan([5 5 0 -4.99 1 1 1])
%appr.ao.outputSingleScan([5 5 0 0 1 1 1])


fwrite(s,[255,0]); % starts tracking acquisition

timer1      =   tic;
while (toc(timer1) < expr.c_trial.trial_time)...
        && (expr.c_trial.data.safe_frames < expr.c_trial.reward_frames) ...
        && expr.c_trial.data.end_trial == 0
 
    pause(.001) % waits for experiment to finish
end

if expr.camera.do_capture == 1
% stops camera
    expr.camera.vidObj.stopCapture();
end

% stops logging
fwrite(s,[254,0]);
fclose(s);
fclose('all');
delete(s);

% turn off arena
appr.ao.outputSingleScan([5 0 0 -4.99 1 0 0])


expi = expr;
cd(expi.settings.fullpath)
save(expi.c_trial.name, 'expr');

end


%Bytes Available Function
 function baf(obj,event)
global expr
global appr
global timer1
global binvals
global init

%% gets data from ball tracker
%Sometimes this event gets called with no data available... for whatever reason, if so, return
if obj.bytesavailable<obj.bytesavailablefcncount
    disp('returned')
    return
end

% pull the data out of the buffer
raw=fread(obj,obj.bytesavailablefcncount);

%12 bytes per sample, only the first byte of the packet is ever zero
zinds=find(raw==0);

%Check the input stream for appropriate packets.  If the stream contains malformed packets, then restart the interface
if sum(diff(zinds)~=12)>1||(obj.bytesavailablefcncount-zinds(end)+1)~=12
    disp('Packets Dropped, Resetting')
    fwrite(obj,[254,0])
    if obj.bytesavailable>0
            fread(obj,obj.bytesavailable); 
    end
    fwrite(obj,[255,0]);
    return
end

%Extract the data relative to the packet header indices
ind=raw(zinds+1);
md=min(diff(ind));

%Respond to errors in the packet index.  If the packet count jumps more than 1 (255 to 1 counts as 1) then restart interface (missing packets)
if(max(diff(ind))>1)|~(md==1|md==-254)
    disp('Packets Dropped, Resetting 1')
    fwrite(obj,[254,0])
    if obj.bytesavailable>0
            fread(obj,obj.bytesavailable); 
    end
    fwrite(obj,[255,0]);
    return
end

%Raw Data, make motion data signed around zero
raw(zinds+2) = raw(zinds+2)-128;
raw(zinds+3) = raw(zinds+3)-128;
raw(zinds+4) = raw(zinds+4)-128;
raw(zinds+5) = raw(zinds+5)-128;

%Extract Motion Data from stream
x0=raw(zinds+2);
y0=raw(zinds+3);
x1=raw(zinds+4);
y1=raw(zinds+5);
                                     
Vfwd    =    sum(x0)*.7071; %integration rotation for the entire 1/20th of a second
Vss     =    sum(y0)*.7071;
Omega   =    sum(x1)/2;

%fprintf(dataFile,'%d, %d, %d\n',[Vfwd,Vss,Omega]);

expr.c_trial.data.count=expr.c_trial.data.count+1;
expr.c_trial.data.vfwd(expr.c_trial.data.count)   = Vfwd;
expr.c_trial.data.vss(expr.c_trial.data.count)    = Vss;
expr.c_trial.data.om(expr.c_trial.data.count)  = Omega;

if  expr.c_trial.data.state == 1 %% first phase of trial is heating in the dark
    expr.c_trial.data.xpos(expr.c_trial.data.count) =   expr.c_trial.startXYT(1);
    expr.c_trial.data.ypos(expr.c_trial.data.count) =   expr.c_trial.startXYT(2);
    expr.c_trial.data.th(expr.c_trial.data.count)   =   expr.c_trial.startXYT(3);
    
    if expr.c_trial.data.count > expr.c_trial.dark_frames
       expr.c_trial.data.state = expr.c_trial.data.state+1;
       expr.c_trial.data.state_1_2_trans = expr.c_trial.data.count;
    end
    
    expr.c_trial.player.xu = expr.c_trial.data.xpos(expr.c_trial.data.count);
    expr.c_trial.player.yu = expr.c_trial.data.ypos(expr.c_trial.data.count);
    expr.c_trial.player.th = expr.c_trial.data.th(expr.c_trial.data.count);
    
   patternCode = [1];

    
elseif  expr.c_trial.data.state == 2 %% second phase, stripe fixation for at least 5 seconds
    expr.c_trial.data.xpos(expr.c_trial.data.count) =  expr.c_trial.startXYT(1);
    expr.c_trial.data.ypos(expr.c_trial.data.count) =  expr.c_trial.startXYT(2);
    expr.c_trial.data.th(expr.c_trial.data.count)   =  mod(expr.c_trial.data.th(expr.c_trial.data.count-1)+ ...
                                                        ((Omega/expr.settings.ticks_per_deg)*expr.settings.rot_gain),360);
    
    % check rotation from last 500 msec
    lastRotationMag = sum(expr.c_trial.data.om(expr.c_trial.data.count-(expr.settings.hz*.5):expr.c_trial.data.count-1))/expr.settings.ticks_per_deg; 
    
    if abs(lastRotationMag) < 5 && ...
            expr.c_trial.data.count >  (expr.c_trial.data.state_1_2_trans + expr.c_trial.fix_frames)  % if, in the last 500 msec, the fly turns less than 10 deg/sec, move on to next phase
      %  if expr.c_trial.data.th(expr.c_trial.data.count) < 45 || expr.c_trial.data.th(expr.c_trial.data.count) > 315
        expr.c_trial.data.state = expr.c_trial.data.state+1;
         expr.c_trial.data.state_2_3_trans = expr.c_trial.data.count;
         expr.c_trial.data.th(expr.c_trial.data.count)   = 0 ;
      %  end
    end
    
    expr.c_trial.player.xu = expr.c_trial.data.xpos(expr.c_trial.data.count);
    expr.c_trial.player.yu = expr.c_trial.data.ypos(expr.c_trial.data.count);
    expr.c_trial.player.th = expr.c_trial.data.th(expr.c_trial.data.count);
    
    patternCode = [2];
    
elseif expr.c_trial.data.state == 3 %% now, fly has full closed-loop control
    expr.c_trial.data.th(expr.c_trial.data.count)   =  mod(expr.c_trial.data.th(expr.c_trial.data.count-1)+ ...
                                                        ((Omega/expr.settings.ticks_per_deg)*expr.settings.rot_gain),360);
    
    expr.c_trial.data.xpos(expr.c_trial.data.count) = floor(expr.c_trial.data.xpos(expr.c_trial.data.count-1)+...
                                                        (Vfwd*expr.settings.fwd_gain*...
                                                        cosd(expr.c_trial.data.th(expr.c_trial.data.count))) );
    
    % set the min and max of travel
    if expr.c_trial.data.xpos(expr.c_trial.data.count) > expr.settings.max_x
        expr.c_trial.data.xpos(expr.c_trial.data.count) = expr.settings.max_x;
    elseif expr.c_trial.data.xpos(expr.c_trial.data.count) < expr.c_trial.startXYT(1)
        expr.c_trial.data.xpos(expr.c_trial.data.count) = expr.c_trial.startXYT(1);
    end
    
    % if fly hits end, end the trial
    if expr.c_trial.data.xpos(expr.c_trial.data.count) == expr.settings.startXYT(1,1) || ...
            expr.c_trial.data.xpos(expr.c_trial.data.count) == expr.settings.max_x
        if expr.c_trial.data.count > expr.c_trial.data.state_2_3_trans+(1500)
            expr.c_trial.data.end_trial = 1;
        end
    end
    
    expr.c_trial.data.ypos(expr.c_trial.data.count) = expr.c_trial.startXYT(2);
    expr.c_trial.player.xu = expr.c_trial.data.xpos(expr.c_trial.data.count);
    expr.c_trial.player.yu = expr.c_trial.data.ypos(expr.c_trial.data.count);
    expr.c_trial.player.th = expr.c_trial.data.th(expr.c_trial.data.count);
    
    patternCode = [3];    
    
end

cpower = expr.c_trial.light_vec(expr.c_trial.data.count);


expr.c_trial.data.laser_power(expr.c_trial.data.count) = cpower;
clk_out = expr.c_trial.data.clk_sigout(expr.c_trial.data.count);
expr.c_trial.data.clk_csig(expr.c_trial.data.count) = clk_out;

appr.ao.outputSingleScan([5 5 clk_out cpower 0 1 1])

%% checks frame rate
expr.c_trial.data.timestamp(expr.c_trial.data.count)=toc(timer1);
end       



       
