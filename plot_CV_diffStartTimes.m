% plot the measure over different values of cortical start times:
clear all
Tfin = 1200.0;
randSeed_vec = [2000];
N= 256;
targetRate = 8.0;
path = '/Users/JenniferKile/Documents/CIMS_research/MATLAB_things/tripletRule_model/networkTriplet_iSTDP/data_diffRates/';

S = 1:20:1000;
startTimes =[0 100 300 500]; %[0 100 200 300 400 500];
GJvec=[0.0 0.02];
% hold some information for each sim:
CV_GJ = NaN(length(startTimes),length(randSeed_vec));
CV_nonGJ = NaN(length(startTimes),length(randSeed_vec));
entrop_nonGJ = NaN(length(startTimes),length(randSeed_vec));
entrop_GJ = NaN(length(startTimes),length(randSeed_vec));
% GJname = {' without GJs', ' with 2% GJs',' with 5% GJs'};
GJname = {' without GJs', ' with GJs'};

for j = 1:length(randSeed_vec)
    seed = randSeed_vec(j);
    for k = 1:length(startTimes)
        timeForSynapses = startTimes(k);
        if timeForSynapses > 0
            realGJ = GJvec;
        else
            realGJ = 0.0;
        end
        % realGJ = GJvec;
        for kk = 1:length(realGJ)
            probGJs = realGJ(kk);
            nameTune = ['Synapses at ', num2str(timeForSynapses),'s',GJname{kk}];
            endName = ['_iSTDP_allToAll',num2str(N),'cells_rate',num2str(targetRate),'_',num2str(100*probGJs),'PercentSisterGJs_',num2str(timeForSynapses),'sCortLearn_seed',num2str(seed),'_wLGNinhib'];
            % endName = ['_iSTDP_allToAll',num2str(N),'cells_rate',num2str(targetRate),'_',num2str(100*probGJs),'PercentSisterGJs_',num2str(timeForSynapses),'sCortLearn_seed',num2str(seed),'_wLGNinhib'];
            %     endName = ['_iSTDP_radConnect',num2str(N),'cells_rate',num2str(targetRate),'_',num2str(100*probGJs),'PercentSisterGJs_',num2str(timeForSynapses),'sCortLearn_seed',num2str(seed),'_wLGNinhib'];
            % endName = ['_1000s_iSTDP_radConnect256cells_rate8_0PercentSisterGJs_0sCortLearn_seed450']
            name = ['_tripletRule_',num2str(Tfin),'s',endName];
            
            tuningInfo = dlmread([path,['tuningInfo',name,'_FINAL.csv']]); %['tuningInfo_',name,'.csv']]); %should be FR
            spikeTimes = dlmread([path,['neuronSpTimes',name,'.csv']]);
            neuronType = spikeTimes(:,1);
            
            pref = NaN(N,1);
            for jj = 1:N
                [I J] = max(tuningInfo(:,jj));
                pref(jj) = S(J);
            end
            
            pref(neuronType==1) = NaN;
            % sort the preferences
            newPref = sort(pref);
            %take out NaNs
            I = isnan(newPref);
            newPref(I) = [];
%             x_edges_pref = 0:50:990;
            x_edges_pref = 0:100:1000;
            % histogram
            M_pref = histc(newPref,x_edges_pref);
            color_pref = hsv(length(x_edges_pref));
            
            normedM_pref = M_pref./sum(M_pref);
            % measure difference from uniform distribution?
           % if uniform, expect 
           disp(GJname{kk})
            M_uniform = (1./(length(M_pref)-1)).*ones(length(M_pref)-1,1);
            diff = M_uniform-normedM_pref(1:end-1);
%             sum(abs(diff))
%             norm(diff)
            %
%             mean(newPref*(180/500))
%             std(newPref*(180/500),1)
            %%
            figure
            hold on
            for ii = 1:length(x_edges_pref)
                bar(ii,normedM_pref(ii),1,'FaceColor',color_pref(ii,:),'EdgeColor','k','linewidth',2)
            end
            hold on
            plot([1:length(x_edges_pref)-1],M_uniform,'k-','linewidth',2)
            xlim([0.5 length(x_edges_pref)+0.5])
            set(gca,'FontSize',25,'xTick',1:2:length(x_edges_pref)-1,'xTickLabel',{'100','200','300','400','500','600','700','800','900','1000'})
            xtickangle(30)
            xlabel('Orientation preference')
            title([GJname{kk},' start time = ' ,num2str(timeForSynapses)])
            
            %
            figure
            plot([1:length(x_edges_pref)-1],diff,'ko-')
            title(GJname{kk})
            %%
            % w GJ
            if kk == 1
                CV_nonGJ(k) =  std(newPref)/mean(newPref);
                entrop_nonGJ(k) = norm(diff);
            else
                CV_GJ(k) = std(newPref)/mean(newPref);
                entrop_GJ(k) = norm(diff);
            end
            
        end
    end
end
%% plot for diff GJ values
figure
plot(startTimes(1), mean(entrop_nonGJ(1,:)), 'ko','linewidth',2,'MarkerSize',8,'MarkerFaceColor','k')
hold on
h = plot(startTimes(2:end), mean(entrop_nonGJ(2:end,:),2),'o-','linewidth',4,'color',(1/255)*[120 120 120],'MarkerSize',8,'MarkerFaceColor',(1/255)*[220 220 220]);
hold on
g = plot(startTimes(2:end), mean(entrop_GJ(2:end,:),2),'sq-','linewidth',4,'color',(1/255)*[0 180 180],'MarkerSize',10,'MarkerFaceColor',(1/255)*[0 220 220]);
legend([h,g],'without GJs','with GJs')
axis([0 550 0.0 0.4])
set(gca,'fontsize',30)
xlabel('Start time of cortical learning (s)')
ylabel('Difference from uniform')



%% plot measure for different start times
% figure
% plot(startTimes(1), orderNonGJ(1), 'o')
% hold on
% plot(startTimes(2:end),orderGJ_1(2:end),'sq-','linewidth',4,'color',(1/255)*[0 170 170])
% hold on
% plot(startTimes(2:end),orderGJ_2(2:end),'sq-','linewidth',4,'color',(1/255)*[0 230 230])
% hold on
% plot(startTimes(2:end),orderNonGJ(2:end), '*:','linewidth',4, 'color','r')
% set(gca,'fontsize',30)
% legend('no GJs at all','2% GJs during the first week','5% GJs during the first week', 'no GJs during the first week')
% xlabel('Start time of cortical learning (s)')
% ylabel('Mean difference in OP')