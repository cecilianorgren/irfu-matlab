function status = av_minvar_interacitve(x,column)
% AV_MINVAR_INTERACTIVE interactively do the minimum variance analysis
% AV_MINVAR_INTERACTIVE(X,COLUMN)
%  X - vector to use, [x(:,column(1)) x(:,column(2)) x(:,column(3))]
%  COLUMN - which columns to use, if not given use 2,3,4
%
% You can access the results through variable 'ud' that is defined as global
% ud.l - eigenvalues  ud.l(1), ud.l(2),ud.l(3)
% ud.v - eigenvectors (ud.v(1,:), ..), also ud.v1, ud.v2. ud.v3
%  ud.Xminvar - data in minimum variance coordinates
%

warning('caa:cleanup',...
'Function %s is deprecated and will be removed on May 1, 2004.\nUse %s instead',
...
mfilename,'irf_minvar_gui')

global ud
persistent tlim message;
%persistent ud tlim;

if isempty(message), 
    message='You can anytime access all the results from the variable "ud".';
    disp(message);
end

if      nargin < 1, help av_minvar_interactive;return;
elseif  (nargin==1 & isstr(x)), action=x;%disp(['action=' action]);
elseif  isnumeric(x),
    if size(x,2)<3, disp('Vector has too few components');return;end
    if nargin < 2,
        if size(x,2)==3, column=[1 2 3];end
        if size(x,2)>3, column=[2 3 4];end
    end
    action='initialize';
end

switch action,
    case 'initialize'
        % X is used for minimum variance estimates
        tlim = [];
        evalin('base','clear ud; global ud;');

        if min(column)==1, time_vector=1:size(x,1);
        elseif min(column)>1, time_vector=x(:,1);
        end

        X=[time_vector x(:,column)];X=av_abs(X);
        ud={}; % structure to pass all information to manager function
        ud.X=X;
        ud.from = 1; % first click with mouse is 'from', second is 'to'
        ud.cancel = 0;
        tlim = [min(X(:,1)) max(X(:,1))];
        ud.tlim_mva=tlim+[-1 1]; % default tlim_mva includes all interval, add 1s to help later in program

        dgh=figure;clf;av_figmenu;
        h(1)=subplot(4,1,1);
        av_tplot(X);axis tight;
        set(dgh,    'windowbuttondownfcn', 'av_minvar_interactive(''ax'')');zoom off;
        av_pl_info(['av\_minvar\_interactive() ' datestr(now)]); % add information to the plot
        set(h(1),'layer','top');
        ax=axis;grid on;
        ud.mvar_intervals=patch([tlim(1) tlim(2) tlim(2) tlim(1)],[ax(3) ax(3) ax(4) ax(4)],[-1 -1 -1 -1],'y','buttondownfcn', 'av_minvar_interactive(''ax'')');

        h(2)=subplot(4,1,2);
        av_tplot(X);axis tight; 
        zoom off;

        h(3)=subplot(4,2,5);

        h(4)=subplot(4,2,6);

        ud.h=h;

        xp=0.2;yp=0.2;
        ud.fromtext=uicontrol('style', 'text', 'string', 'From:','units','normalized', 'position', [xp yp 0.1 0.04],'backgroundcolor','red');
        ud.fromh = uicontrol('style', 'edit', ...
            'string', strrep(datestr(datenum(fromepoch(tlim(1))), 0),' ','_'), ...
            'callback', 'av_minvar_interactive(''from'')', ...
            'backgroundcolor','white','units','normalized','position', [xp+0.11 yp 0.25 0.05]);

        yp=0.15;
        ud.totext=uicontrol('style', 'text', 'string', 'To:','units','normalized', 'position', [xp yp 0.1 0.04],'backgroundcolor','white');
        ud.toh=uicontrol('style', 'edit', ...
            'string', strrep(datestr(datenum(fromepoch(tlim(2))), 0),' ','_'), ...
            'callback', 'av_minvar_interactive(''from'')','backgroundcolor','white','units','normalized', 'position', [xp+0.11 yp 0.25 0.05]);


        xp=0.1;yp=0.1;
        uch1 = uicontrol('style', 'text', 'string', 'Low pass filter f/Fs = ','units','normalized','position', [xp yp 0.2 0.04],'backgroundcolor','white');
        ud.filter = uicontrol('style', 'edit', ...
            'string', '1', ...
            'callback', 'c_4_v_update(''dt'')', ...
            'backgroundcolor','white','units','normalized','position', [xp+0.21 yp 0.1 0.05]);

        uimenu('label','&Recalculate','accelerator','r','callback','av_minvar_interactive(''mva'')');

        subplot(4,2,8);axis off;
        ud.result_text=text(0,0.8,'result');

        av_minvar_interactive('from');
        fix_legends;

    case 'ax'
        tlim = get(ud.mvar_intervals, 'xdata'); tlim=tlim(:)';tlim(3:4)=[];
        p = get(gca, 'currentpoint');
        tlim_interval=get(gca,'xlim');
        if ud.from
            tlim(1) = max(tlim_interval(1), p(1));
            tlim(2) = max(p(1),tlim(2));
            set(ud.fromtext,'backgroundcolor','w');
            set(ud.totext,'backgroundcolor','r');
            ud.from = 0;
        else
            tlim(2) = min(tlim_interval(2), p(1));
            tlim(1) = min(tlim(1), p(1));
            set(ud.totext,'backgroundcolor','w');
            set(ud.fromtext,'backgroundcolor','r');
            ud.from = 1;
        end
        strfrom=datestr(datenum(fromepoch(tlim(1))), 0);
        set(ud.fromh, 'string', strfrom);
        strto=datestr(datenum(fromepoch(tlim(2))), 0);
        set(ud.toh, 'string', strto);
        set(ud.mvar_intervals,'xdata',[tlim(1) tlim(2) tlim(2) tlim(1)]);
        av_minvar_interactive('update_mva_axis');
    case 'from'
        tlim(1) = toepoch(datevec(strrep(get(ud.fromh, 'string'),'_',' ')));
        tlim(2) = toepoch(datevec(strrep(get(ud.toh, 'string'),'_',' ')));
        set(ud.mvar_intervals,'xdata',[tlim(1) tlim(2) tlim(2) tlim(1)]);
        av_minvar_interactive('update_mva_axis');
    case 'update_mva_axis'
        if tlim==ud.tlim_mva, % plot first time after 'mva'
            axes(ud.h(2));
            av_tplot(ud.Xminvar);
            axis tight;add_timeaxis(ud.h(2),'date');
            axes(ud.h(3));
            plot(ud.Xminvar(:,4),ud.Xminvar(:,2));xlabel('min');ylabel('max');
            axis tight;axis equal; ax=axis;grid on;
            axes(ud.h(4))
            plot(ud.Xminvar(:,3),ud.Xminvar(:,2));xlabel('interm');ylabel('max');
            axis equal; grid on;
        elseif (tlim(1)>=ud.tlim_mva(1) & tlim(2)<=ud.tlim_mva(2)) % zoom to something within tlim_mva
            av_zoom(tlim,'x',ud.h(2));
        else                   % zoom to interval outside mva
            X=av_t_lim(ud.X,tlim);
            clear ud.Xminvar;
            ud.Xminvar=av_newxyz(X,ud.v1,ud.v2,ud.v3);
            axes(ud.h(2));
            av_tplot(ud.Xminvar);
            axis tight;add_timeaxis(ud.h(2),'date');
        end
        if (tlim(1)<ud.tlim_mva(1) | tlim(2)>ud.tlim_mva(2)) % if zooming outside tlim_mva mark mva interval
            axes(ud.h(2));set(ud.h(2),'layer','top');
            ax=axis;grid on;
            ud.mvar_interval_2nd=patch([ud.tlim_mva(1) ud.tlim_mva(2) ud.tlim_mva(2) ud.tlim_mva(1)],[ax(3) ax(3) ax(4) ax(4)],[-1 -1 -1 -1],'y','buttondownfcn', 'av_minvar_interactive(''ax'')');
        end
        fix_legends;
    case 'mva'
        ud.tlim_mva=tlim;
        X=av_t_lim(ud.X,tlim);
        clear ud.Xminvar;
        [ud.Xminvar, l, v]=av_minvar(X);
        ud.l=l;ud.v=v;ud.v1=v(1,:);ud.v2=v(2,:);ud.v3=v(3,:);
        l_str=['L1=' num2str(l(1),3) ' L2=' num2str(l(2),3) ' L3=' num2str(l(3),3) '\newline'];
        lratio_str=['L1/L2=' num2str(l(1)/l(2),2) ' L2/L3=' num2str(l(2)/l(3),2) '\newline'];
        v1_str=['v1=[' num2str(v(1,:),'%6.2f') '] \newline'];
        v2_str=['v2=[' num2str(v(2,:),'%6.2f') '] \newline'];
        v3_str=['v3=[' num2str(v(3,:),'%6.2f') '] \newline'];
        v_str=[v1_str v2_str v3_str];
        set(ud.result_text,'string',[l_str lratio_str v_str],'verticalalignment','top');
        av_minvar_interactive('update_mva_axis');
end

end


function fix_legends
global ud

switch size(ud.X,2)-1, % how many components
    case 3 %
        legend(ud.h(1),'x','y','z','Location','EastOutside');
        legend(ud.h(2),'max','interm','min','Location','EastOutside');
    case 4 %
        legend(ud.h(1),'x','y','z','abs','Location','EastOutside');
        legend(ud.h(2),'max','interm','min','abs','Location','EastOutside');
end
end
