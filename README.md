# Buck-Converter-RL
Reinforcement learning as a control technique for the duty cycle, and therefore output voltage, of a 24:12V buck converter using IGBT's.

Reward function for the Agent was set up such that a high penalty was gievn for an output vltage outwith +/-1V of the desired output and a higher reward gievn for an utput voltage nearer to 12V. Additionally, had the agent outputtted exactly the desired output voltgae then a very hih rewrda would have beeen given.
