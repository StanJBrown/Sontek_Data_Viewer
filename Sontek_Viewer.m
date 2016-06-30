
function Sontek_Viewer()
try
screen_size = get(0,'MonitorPositions');
xlength = screen_size(1,3)*.95;    
ylength = screen_size(1,4)-200;
catch  %#ok<CTCH>
    xlength = 800;
    ylength = 400;
end


close all
GUI()


function GUI()


h.mainfigure = figure('Visible','on','Position',[50, 50,xlength,ylength]);
set(h.mainfigure, 'ResizeFcn',@Resize_Cback,...    %the ResizeFcn is called every time the figure size is modified. 
    'Toolbar','figure',...                         %turn on the toolbar which may be of use
    'MenuBar','none',... % 'number','off',...                        %turn of the defualt menu, I will make my own 
    'color',[0.94,0.94,0.94],...     
    'visible','off'); % Note in Stam's original code 'number' was set to 'off',...

% Stuff below configures the default figure toolbar to display only the tools we want
%%%%   get(findall(gcf,'-regexp','Tag','.'),'Tag')  
set(findall(gcf,'tag','Plottools.PlottoolsOn'),         'visible','off');
set(findall(gcf,'tag','DataManager.Linking'),           'visible','off');
set(findall(gcf,'tag','Annotation.InsertLegend'),       'visible','on');
set(findall(gcf,'tag','Annotation.InsertColorbar'),     'visible','on');
set(findall(gcf,'tag','Exploration.Brushing'),          'visible','off');
set(findall(gcf,'tag','Standard.PrintFigure'),          'visible','off');
set(findall(gcf,'tag','Standard.SaveFigure'),           'visible','off');
set(findall(gcf,'tag','Standard.FileOpen'),             'visible','off');
set(findall(gcf,'tag','Standard.NewFigure'),            'visible','off');
set(findall(gcf,'tag','Exploration.Rotate'),            'visible','off');
set(findall(gcf,'tag','Plottools.PlottoolsOff'),        'visible','off');
set(findall(gcf,'tag','Standard.EditPlot'),             'visible','off');

%there are spereator lines that are on by deafult, so all of them are just
%turned off here
set(findall(gcf,'tag','Plottools.PlottoolsOn'),         'Separator','off');
set(findall(gcf,'tag','DataManager.Linking'),           'Separator','off');
set(findall(gcf,'tag','Annotation.InsertLegend'),       'Separator','off');
set(findall(gcf,'tag','Annotation.InsertColorbar'),     'Separator','off');
set(findall(gcf,'tag','Exploration.Brushing'),          'Separator','off');
set(findall(gcf,'tag','Standard.PrintFigure'),          'Separator','off');
set(findall(gcf,'tag','Standard.SaveFigure'),           'Separator','off');
set(findall(gcf,'tag','Standard.FileOpen'),             'Separator','off');
set(findall(gcf,'tag','Standard.NewFigure'),            'Separator','off');
set(findall(gcf,'tag','Exploration.Rotate'),            'Separator','off');
set(findall(gcf,'tag','Exploration.Pan'),               'Separator','on');
set(findall(gcf,'tag','Exploration.ZoomIn'),            'Separator','off');
set(findall(gcf,'tag','Plottools.PlottoolsOff'),        'Separator','off');
set(findall(gcf,'tag','Standard.EditPlot'),             'Separator','off');
set(findall(gcf,'tag','Exploration.DataCursor'),        'Separator','on');   

h.Sample_num = 1;
h.Beam_num = 1;

File_Menu = uimenu(h.mainfigure,'Label','File');

%uimenu(File_Menu,'Label', 'New',                        'Callback', @New_File_Function);
uimenu(File_Menu,'Label', 'Open a different Sontek IQ File',       'Callback', @Open_another_file);
Export_menu = uimenu(File_Menu,'Label', 'Export'                                   );
    Export_All = uimenu(Export_menu, 'Label', 'All Data',                  'Callback', @Export_Data);
    Export_SNR = uimenu(Export_menu, 'Label', 'Signal to Noise Ratio','Callback', @Export_Data,'enable','on');
    Export_Vel_Plot = uimenu(Export_menu, 'Label', 'Current Velocity Profile', 'Callback', @Export_Data,'enable','on');
    Export_Beam_Plot = uimenu(Export_menu, 'Label', 'Current Beam Profile',    'Callback', @Export_Data,'enable','on');
    
uimenu(File_Menu,'Label', 'Quit',                       'Callback', @Open_MatFile);


    function Open_another_file(~,~)
        Sontek_Viewer()
    end
        
%figpos = get(h.mainfigure,'Position'); % this provides variables of the figure size, location ect when the figure is changed.

Vel_axis = axes('Parent',h.mainfigure,'Units','pixels','box','on','Position', [1,1,1000,1000],'visible','on','Tickdir','in','TickLength',[0.005,1]);
        xlabel(Vel_axis,'Downstream Water Velocity [ms^{-1}]')
        ylabel(Vel_axis,'Depth [m]')
        title(Vel_axis,'Beam Velocity Measurements')
        legend(Vel_axis,'Beam 1','Beam 2', 'Beam 3', 'Beam 4')
        
        
  Vel_axis_next_sample_button =  uicontrol('Style','pushbutton','String',...
     'Next Sample','Callback', @Change_Vel_plot,'Parent',h.mainfigure,'fontsize',10);
 
  Vel_axis_prev_sample_button =  uicontrol('Style','pushbutton','String',...
     'Previous Sample','Callback', @Change_Vel_plot,'Parent',h.mainfigure,'fontsize',10);
 
  Colormap_axis_next_beam_button =  uicontrol('Style','pushbutton','String',...
     'Next Beam','Callback', @Change_Beam_plot,'Parent',h.mainfigure,'fontsize',10);
 
  Colormap_axis_prev_beam_button =  uicontrol('Style','pushbutton','String',...
     'Previous Beam','Callback', @Change_Beam_plot,'Parent',h.mainfigure,'fontsize',10);
        

Colormap_axis = axes('Parent',h.mainfigure,'Units','pixels','box','on','Position', [1,1,1,1],'visible','on','Tickdir','in','TickLength',...
                     [0.005,1],'ButtonDownFcn', @Start_Drag_Function);
    %datetick(Colormap_axis,'x','mmm-dd HH:MM')
    xlabel(Colormap_axis ,'Sampling Time')
    ylabel(Colormap_axis ,'Depth [m]')
    title(Colormap_axis ,'Beam One: Facing Upstream ')  
    c = colorbar;
    ylabel(c,'Water Velocity [ms^{-1}]')
    


SNR_axis = axes('Parent',h.mainfigure,'Units','pixels','box','on','Position', [1,1,1000,1000],'visible','on','Tickdir','in','TickLength',...
                [0.005,1],'ButtonDownFcn', @Start_Drag_Function);
    %datetick(SNR_axis,'x','mmm-dd HH:MM')
    xlabel(SNR_axis,'Sampling Time')
    ylabel(SNR_axis,'Signal to Noise Ratio')
    title(SNR_axis,'Signal to Noise Ratio For each Sample Taken')
    
    
    

beam_0_line = line(NaN,NaN, 'Parent', Vel_axis,'color','g', 'HitTest','off','MarkerFaceColor','g','Markersize',2);
beam_1_line = line(NaN,NaN, 'Parent', Vel_axis,'color','b', 'HitTest','off','MarkerFaceColor','b','Markersize',2);
beam_2_line = line(NaN,NaN, 'Parent', Vel_axis,'color','r', 'HitTest','off','MarkerFaceColor','r','Markersize',2);
beam_3_line = line(NaN,NaN, 'Parent', Vel_axis,'color','c', 'HitTest','off','MarkerFaceColor','c','Markersize',2);


SNR_0_line = line(NaN,NaN, 'Parent', SNR_axis,'color','g', 'HitTest','off','MarkerFaceColor','g','Markersize',2);
SNR_1_line = line(NaN,NaN, 'Parent', SNR_axis,'color','b', 'HitTest','off','MarkerFaceColor','b','Markersize',2);
SNR_2_line = line(NaN,NaN, 'Parent', SNR_axis,'color','r', 'HitTest','off','MarkerFaceColor','r','Markersize',2);
SNR_3_line = line(NaN,NaN, 'Parent', SNR_axis,'color','c', 'HitTest','off','MarkerFaceColor','c','Markersize',2);

SNR_Sample_line     = line(NaN, NaN, 'Parent', SNR_axis,'color','k', 'HitTest','off','MarkerFaceColor','k','Markersize',2);
h.Cmap_Sample_line    = line(NaN, NaN, 'Parent', Colormap_axis,'color','k', 'HitTest','off','MarkerFaceColor','k','Markersize',2);

set(h.mainfigure,'visible','on')

    function Resize_Cback(~,~)
          figpos = get(h.mainfigure,'Position');
            set(Vel_axis,                         'Position', [075,  (figpos(4)/4)+100, ((figpos(3)-200)/2), 3*(figpos(4)/4)-165]);
            set(Colormap_axis,                    'Position', [((figpos(3)-200)/2+150),  (figpos(4)/4)+100, (figpos(3)/2-150), 3*(figpos(4)/4)-165]); 
            set(SNR_axis,                         'Position', [075,  60,                (figpos(3)-150), (figpos(4)/4)-50]);       
          
            set(Vel_axis_next_sample_button,      'Position', [75+((figpos(3)-200)/2)-((figpos(3)-200)/8) , (figpos(4)-30), ((figpos(3)-200)/8), 30]);
            set(Vel_axis_prev_sample_button,      'Position', [75 , (figpos(4)-30), ((figpos(3)-200)/8), 30]);
            
            set(Colormap_axis_next_beam_button,      'Position', [((figpos(3)-200)/2+150)+((figpos(3)-200)/2)-((figpos(3)-200)/8) , (figpos(4)-30), ((figpos(3)-200)/8), 30]);
            set(Colormap_axis_prev_beam_button,      'Position', [((figpos(3)-200)/2+150) , (figpos(4)-30), ((figpos(3)-200)/8), 30]);
            
    end
    
     function dateaxis(axis)
         if axis == Vel_axis
             return
         end
              current_limits = get(axis,'Xlim');
              diff = (current_limits(2) - current_limits(1));
               set(axis,'Xtickmode','manual','Ytickmode','auto');
               
               if diff < 1/24/4                    
                  set(axis, 'xtick',floor(current_limits(1)):1/24/12:ceil(current_limits(2)))
                  datetick(axis,'x','dd-mmm HH:MM','keeplimits','keepticks');
               
               elseif diff < 1/24/2                    
                  set(axis, 'xtick',floor(current_limits(1)):1/24/6:ceil(current_limits(2)))
                  datetick(axis,'x','dd-mmm HH:MM','keeplimits','keepticks'); 
               
               elseif diff < 1/24                    
                  set(axis, 'xtick',floor(current_limits(1)):1/24/4:ceil(current_limits(2)))
                  datetick(axis,'x','dd-mmm HH:MM','keeplimits','keepticks');                 
              elseif    diff < 3/24                  
                  set(axis, 'xtick',floor(current_limits(1)):1/24/2:ceil(current_limits(2)))
                  datetick(axis,'x','dd-mmm HH:MM','keeplimits','keepticks');
                 
              elseif    diff < 6/24  
                  set(axis, 'xtick',floor(current_limits(1)):1/24:ceil(current_limits(2)))
                  datetick(axis,'x','dd-mmm-yy HH:MM','keeplimits','keepticks');
                                 
              elseif    diff < 12/24
                  set(axis, 'xtick',floor(current_limits(1)):3/24:ceil(current_limits(2)))
                  datetick(axis,'x','dd-mmm-yy HH:MM','keeplimits','keepticks');
              elseif    diff < 3
                  set(axis, 'xtick',floor(current_limits(1)):6/24:ceil(current_limits(2)))
                  datetick(axis,'x','dd-mmm-yy HH:MM','keeplimits','keepticks');
%               elseif    diff < 5 
%                   set(axis, 'xtick',floor(current_limits(1)):12/24:ceil(current_limits(2)))
%                   datetick(axis,'x','dd-mmm-yy HH:MM','keeplimits','keepticks');
              else
                  set(axis,'Xtickmode','auto','Ytickmode','auto');
                  datetick(axis,'x','dd-mmm-yy','keeplimits','keepticks');
              end                  
     end
        
     
     
     function Start_Drag_Function(varargin)
         if length (varargin) == 2;
             source = varargin{1};         
               
             if strcmp( get(h.mainfigure,'selectionType') , 'normal'); %used to trigger ONLY on a left click
                 if source ==  imagehandle;
                     source = get(source,'parent');
                 end
                 
                 currentpnt = get(source,'CurrentPoint');
                 [~, idx] = min(abs(sample_time_dnum - currentpnt(1)));
                 %find closest value from the samples to where the axis was
                 %clicked.
                 xvalue = sample_time_dnum(idx);
                 Ylims_Cmap_axis = get(Colormap_axis,'Ylim');
                 Ylims_SNR_axis = get(SNR_axis,'Ylim');
                 
                 set(SNR_Sample_line,'xdata',[xvalue,xvalue],'ydata',[Ylims_SNR_axis(1),Ylims_SNR_axis(2)])
                 get(h.Cmap_Sample_line)
                 set(h.Cmap_Sample_line,'xdata',[xvalue,xvalue],'ydata',[Ylims_Cmap_axis(1),Ylims_Cmap_axis(2)])
                 
                 h.Sample_num = idx;
                 Change_Vel_plot()                 
                 
             end
         else
             idx = h.Sample_num;
             xvalue = sample_time_dnum(idx);
             Ylims_Cmap_axis = get(Colormap_axis,'Ylim');
             Ylims_SNR_axis = get(SNR_axis,'Ylim');
             
             set(SNR_Sample_line,'xdata',[xvalue,xvalue],'ydata',[Ylims_SNR_axis(1),Ylims_SNR_axis(2)])
             get(h.Cmap_Sample_line)
             set(h.Cmap_Sample_line,'xdata',[xvalue,xvalue],'ydata',[Ylims_Cmap_axis(1),Ylims_Cmap_axis(2)])             
         end
                
    end
     
     
     
    
%% move this to a loading script

[filenamestr, filepathstr] = uigetfile('.mat');

Resize_Cback % This refreshes plot

IQ_Data = load([filepathstr,filenamestr]);
sample_time_dnum = datenum((IQ_Data.FlowData_SampleTime/1000/1000+datenum(2000,1,1,0,0,0)*60*60*24)/60/60/24);
IQ_Beam_Transform_Matrix = [-1.1831,1.1831,0,0;...
                            0.55170,0.55170,0,0;...
                            0,0,-2.30940,0;...
                            0,0,0,-2.30940];
   
delta_length =  size(IQ_Data.Profile_2_Vel,2)-size(IQ_Data.Profile_0_Vel,2);                      
                        
if delta_length > 0;
    IQ_Data.Profile_0_Vel =  [IQ_Data.Profile_0_Vel, NaN(size(IQ_Data.Profile_0_Vel,1),delta_length)]   ;
    IQ_Data.Profile_1_Vel =  [IQ_Data.Profile_1_Vel, NaN(size(IQ_Data.Profile_1_Vel,1),delta_length)] ;
    
    IQ_Data.Profile_0_VelStd =  [IQ_Data.Profile_0_VelStd , NaN(size(IQ_Data.Profile_0_VelStd ,1),delta_length)]   ;
    IQ_Data.Profile_1_VelStd  =  [IQ_Data.Profile_1_VelStd , NaN(size(IQ_Data.Profile_1_VelStd ,1),delta_length)] ;
    
    IQ_Data.Profile_0_Amp =  [IQ_Data.Profile_0_Amp, NaN(size(IQ_Data.Profile_0_Amp,1),delta_length)]   ;
    IQ_Data.Profile_1_Amp =  [IQ_Data.Profile_1_Amp, NaN(size(IQ_Data.Profile_1_Amp,1),delta_length)] ;
else
    IQ_Data.Profile_2_Vel =  [IQ_Data.Profile_2_Vel, NaN(size(IQ_Data.Profile_2_Vel,1),-delta_length)]   ;
    IQ_Data.Profile_3_Vel =  [IQ_Data.Profile_3_Vel, NaN(size(IQ_Data.Profile_3_Vel,1),-delta_length)] ;
    
    IQ_Data.Profile_2_VelStd =  [IQ_Data.Profile_2_VelStd , NaN(size(IQ_Data.Profile_2_VelStd ,1),-delta_length)]   ;
    IQ_Data.Profile_3_VelStd  =  [IQ_Data.Profile_3_VelStd , NaN(size(IQ_Data.Profile_3_VelStd ,1),-delta_length)] ;
    
    IQ_Data.Profile_2_Amp =  [IQ_Data.Profile_2_Amp, NaN(size(IQ_Data.Profile_2_Amp,1),-delta_length)]   ;
    IQ_Data.Profile_3_Amp =  [IQ_Data.Profile_3_Amp, NaN(size(IQ_Data.Profile_3_Amp,1),-delta_length)] ;
end
    Vel_matrix = NaN(4,size(IQ_Data.Profile_1_Vel,2),size(IQ_Data.Profile_1_Vel,1),1) ;
    Vel_Std_matrix = Vel_matrix;
    Vel_Amp_matrix = Vel_matrix;
    
 
 
 for n = 1:size(IQ_Data.Profile_0_Vel,1)
    
     Vel_matrix(:,:,n) = IQ_Beam_Transform_Matrix*[IQ_Data.Profile_0_Vel(n,:); IQ_Data.Profile_1_Vel(n,:); IQ_Data.Profile_2_Vel(n,:); IQ_Data.Profile_3_Vel(n,:)];
     Vel_Std_matrix(:,:,n)    = abs(IQ_Beam_Transform_Matrix)*[IQ_Data.Profile_0_VelStd(n,:);IQ_Data.Profile_1_VelStd(n,:);IQ_Data.Profile_2_VelStd(n,:);IQ_Data.Profile_3_VelStd(n,:)];
     Vel_Amp_matrix(:,:,n)    = abs(IQ_Beam_Transform_Matrix)*[IQ_Data.Profile_0_Amp(n,:);IQ_Data.Profile_1_Amp(n,:);IQ_Data.Profile_2_Amp(n,:);IQ_Data.Profile_3_Amp(n,:)];
     
     index = double(Vel_Std_matrix(1,:,n) <0);
     index(index == 1) = NaN;
     
     Vel_matrix(1:2,:,n) = Vel_matrix(1:2,:,n) + repmat(index,2,1);
     Vel_Std_matrix(1:2,:,n)    = Vel_Std_matrix(1:2,:,n) + repmat(index,2,1);
     Vel_Amp_matrix(1:2,:,n)    = Vel_Amp_matrix(1:2,:,n) + repmat(index,2,1);    
 end
                  
        skew_depth_raw = ((1:1:80).*IQ_Data.FlowSubData_PrfHeader_2_CellSize(h.Sample_num)+IQ_Data.FlowSubData_PrfHeader_2_BlankingDistance(h.Sample_num))/1000;
        inline_depth_raw = ((1:1:80).*IQ_Data.FlowSubData_PrfHeader_0_CellSize(h.Sample_num)+IQ_Data.FlowSubData_PrfHeader_0_BlankingDistance(h.Sample_num))/1000;
        Vel_Beam_1_2_index_1 = inline_depth_raw < IQ_Data.FlowData_Depth(h.Sample_num);
        Vel_Beam_3_4_index_2 = skew_depth_raw < IQ_Data.FlowData_Depth(h.Sample_num); 
        
        Change_Vel_plot()
        legend(Vel_axis,'Upstream','Downstream','Left Beam','Right Beam', 'Location','SouthEast' )
        title(Vel_axis,{'Beam Velocity Profile at:' datestr(sample_time_dnum(h.Sample_num))});
        
        
    function Change_Vel_plot(varargin)
        if length(varargin) == 2;
            if varargin{1} == Vel_axis_next_sample_button
                h.Sample_num = h.Sample_num + 1;
            elseif  varargin{1} == Vel_axis_prev_sample_button
                h.Sample_num = h.Sample_num - 1;
            end
            
            if h.Sample_num == 0
                h.Sample_num = length(sample_time_dnum);
            end
            
            if h.Sample_num == (length(sample_time_dnum)+1)
                h.Sample_num = 1;
            end
            Start_Drag_Function()
            
        end
        
       
        
        set(beam_0_line,'xdata',Vel_matrix(1,Vel_Beam_1_2_index_1,h.Sample_num)/1000,'ydata',inline_depth_raw(Vel_Beam_1_2_index_1));
        set(beam_1_line,'xdata',Vel_matrix(2,Vel_Beam_1_2_index_1,h.Sample_num)/1000,'ydata',inline_depth_raw(Vel_Beam_1_2_index_1));
        set(beam_2_line,'xdata',Vel_matrix(3,Vel_Beam_3_4_index_2,h.Sample_num)/1000,'ydata',skew_depth_raw(Vel_Beam_3_4_index_2));
        set(beam_3_line,'xdata',Vel_matrix(4,Vel_Beam_3_4_index_2,h.Sample_num)/1000,'ydata',skew_depth_raw(Vel_Beam_3_4_index_2));
        title(Vel_axis,{'Beam Velocity Profile at:' datestr(sample_time_dnum(h.Sample_num))})
    end
    

    

%% SNR thing                        
%Beam 1 and 2 are denoted by profile 0 and 1;

set(SNR_0_line, 'xdata',sample_time_dnum,'ydata',IQ_Data.FlowData_SNR(:,1));
set(SNR_1_line, 'xdata',sample_time_dnum,'ydata',IQ_Data.FlowData_SNR(:,2));
set(SNR_2_line, 'xdata',sample_time_dnum,'ydata',IQ_Data.FlowData_SNR(:,3));
set(SNR_3_line, 'xdata',sample_time_dnum,'ydata',IQ_Data.FlowData_SNR(:,4));
dateaxis(SNR_axis)
legend(SNR_axis,'Upstream','Downstream', 'Left Beam', 'Right Beam')

%%

Beam_1_and_2_offset_from_Verticle = cos((0)*pi/180);



%depth_Beam_1 = zeros(size(Profile_0_Vel,1),size(Profile_0_Vel,2));
cell_number = repmat(1:size(IQ_Data.Profile_0_Vel,2),size(IQ_Data.Profile_0_Vel,1),1);
offset = repmat(IQ_Data.FlowSubData_PrfHeader_0_BlankingDistance,1,size(IQ_Data.Profile_0_Vel,2));
cell_lengths =  repmat(IQ_Data.FlowSubData_PrfHeader_0_CellSize,1,size(IQ_Data.Profile_0_Vel,2));
depth = (offset+cell_number.*cell_lengths.*Beam_1_and_2_offset_from_Verticle)/1000;

plotting = -IQ_Data.Profile_0_Vel/1000;
plotting(abs(plotting)>100000) = -0.01;
x = IQ_Data.FlowSubData_FirstAdpSampleTime;
x = datenum((x/1000/1000+datenum(2000,1,1,0,0,0)*60*60*24)/60/60/24);
y = depth(end,:);


% new thing to make a pcolor map cuz the other one is shit
imagehandle = imagesc([min(x),max(x)],[min(y(Vel_Beam_1_2_index_1)),max(y(Vel_Beam_1_2_index_1))],plotting(:,Vel_Beam_1_2_index_1)','parent',Colormap_axis,'ButtonDownFcn', @Start_Drag_Function);
cmap = colormap(Colormap_axis);
cmap(1,:) = [1 1 1];
colormap(Colormap_axis,cmap)
c = colorbar('peer',Colormap_axis);
ylabel(c,'Water Velocity [ms^{-1}]')
set(Colormap_axis,'xlim',[min(x),max(x)],'YDir','normal')
dateaxis(Colormap_axis)
xlabel(Colormap_axis ,'Sampling Time')
ylabel(Colormap_axis ,'Depth [m]')
title(Colormap_axis ,'Beam One: Facing Upstream ') 
%this line must be made after the imagesc call as it appears matlab likes
%to delete all other children from an axis when imagesc is called
%unfortunatly. 
h.Cmap_Sample_line    = line(NaN, NaN, 'Parent', Colormap_axis,'color','k', 'HitTest','off','MarkerFaceColor','k','Markersize',2);
%Change_beam_plot

    function Change_Beam_plot(varargin)
        if length(varargin) == 2;
            if varargin{1} == Colormap_axis_next_beam_button
                h.Beam_num = h.Beam_num + 1;
            elseif  varargin{1} == Colormap_axis_prev_beam_button
                h.Beam_num = h.Beam_num - 1;
            end
        else
            h.Beam_num = 1;
        end
        
        if h.Beam_num == 5
            h.Beam_num = 1;
        end
        
        if h.Beam_num == 0
            h.Beam_num = 4;
        end
        
             
%         Vel_matrix(1,Vel_Beam_1_2_index_1,h.Sample_num)/1000
       % cmap_plot_data = IQ_Data.(sprintf(strcat('Profile_',num2str(h.Beam_num-1),'_Vel')));
       cmap_plot_data = Vel_matrix(h.Beam_num,:,:);
       cmap_plot_data = permute(cmap_plot_data,[3, 2, 1]);
        
        cmap_Blanking_distance = IQ_Data.(sprintf(strcat('FlowSubData_PrfHeader_',num2str(h.Beam_num-1),'_BlankingDistance')));
        cmap_Cell_Size = IQ_Data.(sprintf(strcat('FlowSubData_PrfHeader_',num2str(h.Beam_num-1),'_CellSize')));
        
        cell_number = repmat(1:size(cmap_plot_data,2),size(cmap_plot_data,1),1);
        offset = repmat(cmap_Blanking_distance,1,size(cmap_plot_data,2));
        cell_lengths =  repmat(cmap_Cell_Size,1,size(cmap_plot_data,2));
        
        if h.Beam_num == 3 || h.Beam_num == 4;
             depth = (offset+cell_number.*cell_lengths.*cos(60*pi/180))/1000;
        else
            depth = (offset+cell_number.*cell_lengths.*cos(0*pi/180))/1000;
        end
        
        
        plotting = cmap_plot_data/1000;
%         plotting(abs(plotting)>100000) = -0.01;
        x = IQ_Data.FlowSubData_FirstAdpSampleTime;
        x = datenum((x/1000/1000+datenum(2000,1,1,0,0,0)*60*60*24)/60/60/24);
        y = depth(end,:);
        
        
        
         xdata = get(h.Cmap_Sample_line,'xdata');
         ydata = get(h.Cmap_Sample_line, 'ydata');
         
        imagehandle = imagesc([min(x),max(x)],[min(y(Vel_Beam_1_2_index_1)),max(y(Vel_Beam_1_2_index_1))],plotting(:,Vel_Beam_1_2_index_1)',...
            'parent',Colormap_axis, 'ButtonDownFcn', @Start_Drag_Function);
        cmap = colormap(Colormap_axis);
%         if h.Beam_num ==2
%             cmap(end,:) = [1 1 1];
%         else
%             cmap(1,:) = [1 1 1];
%         end
        colormap(Colormap_axis,cmap)
        c = colorbar('peer',Colormap_axis);
        ylabel(c,'Water Velocity [ms^{-1}]')
        set(Colormap_axis,'xlim',[min(x),max(x)],'YDir','normal')
        dateaxis(Colormap_axis)
        xlabel(Colormap_axis ,'Sampling Time')
        ylabel(Colormap_axis ,'Depth [m]')
        
        % could use the following to make the 2 axis match, but colormap
        % cell sizes will cause some plotting 
        %ylim(Colormap_axis, get(Vel_axis, 'ylim'));
        h.Cmap_Sample_line    = line('xdata',xdata ,'ydata', ydata, 'Parent', Colormap_axis,'color','k', 'HitTest','off','MarkerFaceColor','k','Markersize',2);

        
        switch(h.Beam_num)
            case(1)
                Title_string = 'Beam One: Facing Upstream ';
            case(2)
                Title_string = 'Beam Two: Facing Downstream ';
            case(3)
                Title_string = 'Beam Three: Facing Left ';
            case(4)
                Title_string = 'Beam Four: Facing Right ';        
        end
        title(Colormap_axis ,Title_string);                   
       
    end



%% setting up functions to ensure the figure properties behave correctly

%modify the pan properties
    Pan_Properties = pan(gcf); 
                PanContextMenu = uicontextmenu;
            uimenu(PanContextMenu ,'Label','Toggle Pan off','Callback',@toggle_pan_off);
            uimenu(PanContextMenu ,'Label','Contstrain to Horizontal Panning','Callback',@Pan_Constr);
            uimenu(PanContextMenu ,'Label','Contstrain to Vertical Panning','Callback',@Pan_Constr);
            uimenu(PanContextMenu ,'Label','Uncontrained Panning','Callback',@Pan_Constr);
            
            set(Pan_Properties,'UIContextMenu',PanContextMenu)
            set(Pan_Properties,'Enable','off')
            set(Pan_Properties,'ActionPostCallback',@Pan_Call_dateaxis)
     
     function Pan_Constr(source,~) 
         switch(get(source,'Label'))             
             case('Contstrain to Horizontal Panning')
                 set(Pan_Properties,'Motion','horizontal','Enable','on');
             case('Contstrain to Vertical Panning')
                 set(Pan_Properties,'Motion','vertical','Enable','on');
             case('Uncontrained Panning')
                 set(Pan_Properties,'Motion','both','Enable','on');
         end
     end             

                       
     function toggle_pan_off(~,~)
        set(Pan_Properties,'Enable','off')
     end
        
     function Pan_Call_dateaxis(~,~)         
            dateaxis(gca)            
     end


  Zoom_Properties = zoom(gcf);
        set(Zoom_Properties,'Enable','off')
        set(Zoom_Properties,'ActionPostCallback',@Zoom_Call_dateaxis)
     
     
    function Zoom_Call_dateaxis(~,~)
                        dateaxis(gca)               
    end

    function Export_Data(source,~)
        
        [filename, filepath] = uiputfile('.xlsx');
        if filename == 0
            %user has cancelled the uiputfile function, returning 0 so I
            %quit the function here and do not execute anything below.
            return
        end
        
        filepath_str = [filepath,filename];
    
     Excel = actxserver('Excel.Application');
               set(Excel, 'Visible', 0);
               Workbooks = Excel.Workbooks;
               Workbook = invoke(Workbooks, 'Add');
               Sheets = Excel.ActiveWorkBook.Sheets;              
             
               switch(source)
                   case(Export_All)                       
                       Export_VProfile_Data()
                       Export_SNR_Data()
                   case(Export_SNR)
                       Export_SNR_Data()
                   case(Export_Beam_Plot)
                       Export_VProfile_Data()                       
                   case(Export_Vel_Plot)
                       Export_Current_VProfile_Plot()
               end
               
               
              
       
        function Export_SNR_Data()            
            
            Excel.ActiveWorkBook.Sheets.Add();
            sheet1 = get(Sheets, 'Item', 1);
            invoke(sheet1, 'Activate');
            Sheets.Item(1).Name = strcat('SNR_Ratio');
            
            % Get a handle to the active sheet
            Activesheet = Excel.Activesheet;           
            
            ActivesheetRange = get(Activesheet,'Range','A2:A2');
            set(ActivesheetRange, 'Value', 'Sample Time and Date');
            
            ActivesheetRange = get(Activesheet,'Range',strcat('A3:A',num2str(length(IQ_Data.FlowData_SNR(:,1))+2)));
            set(ActivesheetRange, 'Value', cellstr(datestr(sample_time_dnum)));
            ActivesheetRange.NumberFormat = 'd-mmm-yy HH:MM:SS';
            
            
            ActivesheetRange = get(Activesheet,'Range','A1:A1');
            set(ActivesheetRange, 'Value', 'Signal to Noise Ratio');
            
            ActivesheetRange = get(Activesheet,'Range','B2:E2');
            set(ActivesheetRange, 'Value', {'Beam 1', 'Beam 2', 'Beam 3', 'Beam 4'});
            
            ActivesheetRange = get(Activesheet,'Range',strcat('B3:E',num2str(length(IQ_Data.FlowData_SNR(:,1))+2)));
            set(ActivesheetRange, 'Value', IQ_Data.FlowData_SNR(:,1:4));
            
            
        end
               
               
        function Export_VProfile_Data()
               % Put a MATLAB array into Excel
               %name the columns.
               for export_beam = 4:-1:1;
                                      
                   Excel.ActiveWorkBook.Sheets.Add();
                   sheet1 = get(Sheets, 'Item', 1);               
                   invoke(sheet1, 'Activate');  
                   Sheets.Item(1).Name = strcat('Beam_', num2str(export_beam), '_Velocity_Profile');
                   
                   % Get a handle to the active sheet               
                   Activesheet = Excel.Activesheet;
                   
                   [Vel_prof_depth_export,Vel_prof_Export] = Prep_Vel_Profiles(export_beam,'all');
                   
               ActivesheetRange = get(Activesheet,'Range','B1:B1');               
               set(ActivesheetRange, 'Value', 'Water Velocity [m/s]');
               
               ActivesheetRange = get(Activesheet,'Range','A2:A2');               
               set(ActivesheetRange, 'Value', 'Water Column Height [m]'); 
               
               ActivesheetRange = get(Activesheet,'Range',strcat('A3:A',num2str(length(Vel_prof_depth_export)+2)));  
               set(ActivesheetRange, 'Value', Vel_prof_depth_export');
               
               ActivesheetRange = get(Activesheet,'Range',strcat('A3:A',num2str(length(Vel_prof_depth_export)+2)));  
               set(ActivesheetRange, 'Value', Vel_prof_depth_export');
               
               endcolum = ExcelCol(size(Vel_prof_Export,2));               
               
               ActivesheetRange = get(Activesheet,'Range',strcat('B3',':',endcolum{1},num2str(size(Vel_prof_Export,1)+2)));
               set(ActivesheetRange, 'Value', Vel_prof_Export);
               
               ActivesheetRange = get(Activesheet,'Range',strcat('B2',':',endcolum{1},'2'));
               set(ActivesheetRange, 'Value',cellstr(datestr(sample_time_dnum))');
               ActivesheetRange.NumberFormat = 'd-mmm-yy HH:MM:SS';
               
               end
        end
        
        
        function Export_Current_VProfile_Plot()
        
            Excel.ActiveWorkBook.Sheets.Add();
            sheet1 = get(Sheets, 'Item', 1);
            invoke(sheet1, 'Activate');
            Sheets.Item(1).Name = strcat('Velocity_Profile');
            
            depth_data_Beam_1_and_2 = get(beam_0_line,'ydata');
            depth_data_Beam_3_and_4 = get(beam_3_line,'ydata');
            
            Beam_0_Data = get(beam_0_line,'xdata');
            Beam_1_Data = get(beam_1_line,'xdata');
            Beam_2_Data = get(beam_2_line,'xdata');
            Beam_3_Data = get(beam_3_line,'xdata');
                        
            % Get a handle to the active sheet
            Activesheet = Excel.Activesheet;   
            
            ActivesheetRange = get(Activesheet,'Range','a1:a1');               
            set(ActivesheetRange, 'Value', strcat('Water Velocity Profile taken at ', datestr(sample_time_dnum(h.Sample_num))));
                     
            ActivesheetRange = get(Activesheet,'Range','a2:a2');               
            set(ActivesheetRange, 'Value', 'Depth Beam 1 and 2 [m]');
               
            ActivesheetRange = get(Activesheet,'Range',strcat('A3:A',num2str(length(depth_data_Beam_1_and_2)+2)));               
            set(ActivesheetRange, 'Value', depth_data_Beam_1_and_2')
            
            ActivesheetRange = get(Activesheet,'Range','b2:b2');               
            set(ActivesheetRange, 'Value', 'Beam 1 Velocity [m/s]');
               
            ActivesheetRange = get(Activesheet,'Range',strcat('b3:b',num2str(length(Beam_0_Data)+2)));               
            set(ActivesheetRange, 'Value', Beam_0_Data')
            
            ActivesheetRange = get(Activesheet,'Range','c2:c2');               
            set(ActivesheetRange, 'Value', 'Beam 2 Velocity [m/s]');
               
            ActivesheetRange = get(Activesheet,'Range',strcat('c3:c',num2str(length(Beam_0_Data)+2)));               
            set(ActivesheetRange, 'Value', Beam_1_Data')
            
            ActivesheetRange = get(Activesheet,'Range','e2:e2');               
            set(ActivesheetRange, 'Value', 'Depth Beam 3 and 4 [m]');
               
            ActivesheetRange = get(Activesheet,'Range',strcat('e3:e',num2str(length(depth_data_Beam_3_and_4)+2)));               
            set(ActivesheetRange, 'Value', depth_data_Beam_3_and_4')
            
            ActivesheetRange = get(Activesheet,'Range','f2:f2');               
            set(ActivesheetRange, 'Value', 'Beam 3 Velocity [m/s]');
               
            ActivesheetRange = get(Activesheet,'Range',strcat('f3:f',num2str(length(Beam_3_Data)+2)));               
            set(ActivesheetRange, 'Value', Beam_2_Data')
            
            ActivesheetRange = get(Activesheet,'Range','g2:g2');               
            set(ActivesheetRange, 'Value', 'Beam 4 Velocity [m/s]');
               
            ActivesheetRange = get(Activesheet,'Range',strcat('g3:g',num2str(length(Beam_3_Data)+2)));               
            set(ActivesheetRange, 'Value', Beam_3_Data')           
        
        end
               sheet1 = get(Sheets, 'Item', 1);               
               invoke(sheet1, 'Activate');
               % Now save the workbook               
               invoke(Workbook, 'SaveAs', filepath_str);               
               % To avoid saving the workbook and being prompted to do so,               
               % uncomment the following code.               
                Workbook.Saved = 1;               
                invoke(Workbook, 'Close');               
                %Quit Excel               
               invoke(Excel, 'Quit');               
               % End process               
               delete(Excel);
                      
        
                        
        
        function [depth, Vel_Array] = Prep_Vel_Profiles(beam,sample_num);           
            
            
            if beam > 2;
                Vel_Array = Vel_matrix(beam,Vel_Beam_3_4_index_2,:)/1000; 
                depth = inline_depth_raw(Vel_Beam_3_4_index_2);
            else                
                Vel_Array = Vel_matrix(beam,Vel_Beam_1_2_index_1,:)/1000;
                depth = inline_depth_raw(Vel_Beam_1_2_index_1);
            end
            
            Vel_Array = squeeze(Vel_Array);
        end
        
        
        
    end

    function Out=ExcelCol(In)
        %EXCELCOL  Converts between column name and number for Excel representation
        %   Out=ExcelCol(In) takes the input In, which may be a number, vector,
        %   char, or cell and converts it to the other representation
        %
        %   If IN is numeric, output will be a column cell of the column name
        %   If IN is char or cell, output will be a number or column vector,
        %      ignoring any numberic part which may be included in input
        %
        %   EXAMPLES:
        %   ExcelCol(100)                        %Number to column name
        %   ExcelCol('CV')                       %Column name to number
        %   ExcelCol([1 10 100 1000 16383])      %Multiple conversions
        %   ExcelCol({'A' 'J' 'CV' 'ALL' 'XFC'}) %Multiple conversions
        %
        %
        
        %
        % $ Author: Mike Sheppard
        % $ Original Date: 4/7/2010
        % $ Version: 1.0
        
        
        %Optional to change representation and base
        ABC=['ABCDEFGHIJKLMNOPQRSTUVWXYZ'];
        base=26;
        
        if isnumeric(In)
            %Converts from column number to alpha
            %1=A, 2=B,... 26=Z, 27=AA, ... 16383=XFC
            In=In(:);
            if ~all(In>0)
                error('MATLAB:ExcelCol:NegativeColumnNumber', 'Column numbers must be positive');
            end
            for row=1:size(In,1)
                diff=1;
                i=0;
                p=In(row,:);
                while diff<=p
                    letter_ind=1+mod(floor((p-diff)/base^i),base);
                    i=i+1;
                    temp(i)=ABC(letter_ind);
                    diff=diff+base^i;
                end
                Out{row}=fliplr(temp);
                clear temp
            end
            Out=Out(:);
        else
            %Converts from alpha to column number
            %A=1, B=2, ..., Z=26, AA=27, ... XFC=16383
            In=cellstr(upper(In));
            In=In(:);
            for row=1:size(In,1)
                alpha=char(In(row,:));
                %Delete any numbers which may appear
                alpha=(char(regexp(alpha,'\D','match')))';
                lng=length(alpha);
                temp=((base^(lng) - 1) / (base-1));
                for i=1:lng
                    ind=strfind(ABC, alpha(i));
                    if isempty(ind)  %ERROR
                        error('MATLAB:ExcelCol:Mixofcharacters', 'Must be only alpha-numeric values {A-Z}, {a-z}, {0-9}');
                    end
                    temp=temp+(ind-1)*(base^(lng-i));
                end
                Out(row)=temp;
            end
            Out=Out(:);
        end
        
        
    end
    
    
end

end




