# TUTORIAL ONLY - not for production use. See README.md.
# Run an Isaac Sim example headless, even if it asks for a window.
# Usage: /isaac-sim/python.sh headless.py <example.py> [example args...]
import runpy
import sys

import isaacsim

_Base = isaacsim.SimulationApp


class Headless(_Base):
    def __init__(self, launch_config=None, *args, **kwargs):
        launch_config = dict(launch_config or {})
        launch_config["headless"] = True
        super().__init__(launch_config, *args, **kwargs)


isaacsim.SimulationApp = Headless
script = sys.argv[1]
sys.argv = sys.argv[1:]
runpy.run_path(script, run_name="__main__")
