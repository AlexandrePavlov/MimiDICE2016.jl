using MimiDICE2016
using Mimi

m = MimiDICE2016.get_model()	# Get a copy of the default MimiDICE2016 model
mcs = MimiDICE2016.get_mcs()	# Get a copy of the default MimiDICE2016 Monte Carlo Simulation definition

results = run(mcs, m, 1000; trials_output_filename = "/tmp/dice-2016/trialdata.csv", results_output_dir="/tmp/dice-2016")
explore(results)