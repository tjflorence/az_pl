function expi = run_thermo_opto_2p_trial(expi, app, vi)

global expr
global appr
global timer1
global binvals
global init
global vi_obj

vi_obj = vi;
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
appr.ao.outputSingleScan([-4.99 0 0 -4.99 1 0 0])


expi = expr;
cd(expi.settings.fullpath)
save(expi.c_trial.name, 'expr', '-v7.3');

end


%Bytes Available Function
 function baf(obj,event)
global expr
global appr
global timer1
global vi_obj

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


expr.c_trial.data.count=expr.c_trial.data.count+1;
expr.c_trial.data.vfwd(expr.c_trial.data.count)   = Vfwd;
expr.c_trial.data.vss(expr.c_trial.data.count)    = Vss;
expr.c_trial.data.om(expr.c_trial.data.count)  = Omega;

%% controls visual stimulus
if expr.c_trial.data.count == 1
   
    if expr.c_trial.viz_type == 1
        Panel_tcp_com('all_off')
    elseif expr.c_trial.viz_type == 2
        Panel_tcp_com('all_on')   
    elseif expr.c_trial.viz_type == 3
        Panel_tcp_com('set_pattern_id', 1)
        Panel_tcp_com('send_gain_bias', [expr.c_trial.c_gain_pat 0 0 0])
        Panel_tcp_com('stop')
    end    
    
end



if expr.c_trial.stimulus_vec(expr.c_trial.data.count) == 1
   
    if expr.c_trial.viz_type == 1
        Panel_tcp_com('all_on')
    elseif expr.c_trial.viz_type == 2
        Panel_tcp_com('all_off')   
    elseif expr.c_trial.viz_type == 3
        Panel_tcp_com('start')
    end    
    
end


cpower = expr.c_trial.light_vec(expr.c_trial.data.count);
tframe = mod(expr.c_trial.data.count, 2);

if tframe == 1
    clk_out = -5;
else
    clk_out = 5;
end

expr.c_trial.data.laser_power(expr.c_trial.data.count) = cpower;
expr.c_trial.data.clk_csig(expr.c_trial.data.count) = clk_out;

appr.ao.outputSingleScan([5 5 clk_out cpower 0 1 1])

%% checks frame rate
expr.c_trial.data.timestamp(expr.c_trial.data.count)=toc(timer1);

 end       



       
