obsInfo = rlNumericSpec([3 1],...
    'LowerLimit', [-inf -inf 0 ]',...
    'UpperLimit', [inf inf 20]');
%how many parameters am I observing: voltage and current
obsInfo.Name = 'observations';
obsInfo.Description = 'integrated error, error, and voltage';
numObservations = obsInfo.Dimension(1);

%limits set for the output voltage, purely theoretical
    
obsInfo.Name = 'observations';
obsInfo.Description = 'integrated error, error,  measured vout';
numObservations = obsInfo.Dimension(1);

actInfo = rlNumericSpec([1 1]);
actInfo.Name = 'OutputVoltage';
numActions = actInfo.Dimension(1);

env = rlSimulinkEnv('component_model_working', 'component_model_working/RL Agent', obsInfo, actInfo);

Tf = 1;
Ts = 0.00015;
%look inot units and values
rng(0);

statePath = [
    featureInputLayer(numObservations,'Normalization','none','Name','State')
    fullyConnectedLayer(50,'Name','CriticStateFC1')
    reluLayer('Name','CriticRelu1')
    fullyConnectedLayer(25,'Name','CriticStateFC2')];
actionPath = [
    featureInputLayer(numActions,'Normalization','none','Name','Action')
    fullyConnectedLayer(25,'Name','CriticActionFC1')];
commonPath = [
    additionLayer(2,'Name','add')
    reluLayer('Name','CriticCommonRelu')
    fullyConnectedLayer(1,'Name','CriticOutput')];

criticNetwork = layerGraph();
criticNetwork = addLayers(criticNetwork,statePath);
criticNetwork = addLayers(criticNetwork,actionPath);
criticNetwork = addLayers(criticNetwork,commonPath);
criticNetwork = connectLayers(criticNetwork,'CriticStateFC2','add/in1');
criticNetwork = connectLayers(criticNetwork,'CriticActionFC1','add/in2');

figure
plot(criticNetwork)

%break here, everything before is theoretically valid


criticOpts = rlRepresentationOptions('LearnRate',1e-03,'GradientThreshold',1);

critic = rlQValueRepresentation(criticNetwork,obsInfo,actInfo,'Observation',{'State'},'Action',{'Action'},criticOpts);

actorNetwork = [
    featureInputLayer(numObservations,'Normalization','none','Name','State')
    fullyConnectedLayer(3, 'Name','actorFC')
    tanhLayer('Name','actorTanh')
    fullyConnectedLayer(numActions,'Name','Action')
    ];

actorOptions = rlRepresentationOptions('LearnRate',1e-04,'GradientThreshold',1);

actor = rlDeterministicActorRepresentation(actorNetwork,obsInfo,actInfo,'Observation',{'State'},'Action',{'Action'},actorOptions);

agentOpts = rlDDPGAgentOptions(...
    'SampleTime',Ts,...
    'TargetSmoothFactor',1e-3,...
    'DiscountFactor',1.0, ...
    'MiniBatchSize',64, ...
    'ExperienceBufferLength',1e6); 

agentOpts.NoiseOptions.StandardDeviation = 0.3;
agentOpts.NoiseOptions.StandardDeviationDecayRate = 1e-5;
agentOpts.NoiseOptions.MeanAttractionConstant = 2e-3;

agent = rlDDPGAgent(actor,critic,agentOpts);

maxepisodes = 2500;
maxsteps = ceil(Tf/Ts);
trainOpts = rlTrainingOptions(...
    'MaxEpisodes',maxepisodes, ...
    'MaxStepsPerEpisode',maxsteps, ...
    'ScoreAveragingWindowLength',20, ...
    'Verbose',false, ...
    'Plots','training-progress',...
    'StopTrainingCriteria','AverageReward',...
    'StopTrainingValue',20000);

doTraining = true;
if doTraining
    % Train the agent.
    trainingStats = train(agent,env,trainOpts);
else
    % Load the pretrained agent for the example.
    load('WaterTankDDPG.mat','agent')
end


simOpts = rlSimulationOptions('MaxSteps',maxsteps,'StopOnError','on');
experiences = sim(env,agent,simOpts);

function in = localResetFcn(in)

% randomize reference signal
blk = sprintf('Environment_actions_and_observations/Desired outputvoltage');
v = 2*randn + 5;
while v <= 11 || v >= 13
    v = 2*randn + 5;
end
in = setBlockParameter(in,blk,'Value',num2str(v));

% randomize initial voltage
v = 2*randn + 5;
while v <= 11 || v >= 13
    v = 2*randn + 5;
end
blk = 'rlwatertank/Water-Tank System/H';
in = setBlockParameter(in,blk,'InitialCondition',num2str(v));

end
