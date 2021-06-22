# Converter-RL

Using reinforcement learning to explore the possiiblity of controlling power converters. Two projcts are currently beinc completed/have been completed. 

The primary focus of the project would be to explroe using Reinforcement learning to control a 3-phase 2-level convetrer for a wind turbine that uses hysteresis based vector space modulation due to  high rated output power and desired control of the switching frequency.

This model is still in progress with the main simulink model of the converter being modelled.


As such, to gain experience in using RL a buck converter was modelled:

Reinforcement learning as a control technique for the duty cycle, and therefore output voltage, of a 24:12V buck converter using IGBT's.

Reward function for the Agent was set up such that a high penalty was gievn for an output vltage outwith +/-1V of the desired output and a higher reward gievn for an utput voltage nearer to 12V. Additionally, had the agent outputtted exactly the desired output voltgae then a very hih rewrda would have beeen given.

