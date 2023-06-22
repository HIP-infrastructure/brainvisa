# Change the value for FREESURFER_HOME if you have 
# installed Freesurfer into a different location

#only execute if ghostfs is mounted
if mount |grep -q GhostFS
then
  source /casa/install/bin/bv_env.sh /casa/install
fi

# Load the default .profile
[[ -s "$HOME/.profile" ]] && source "$HOME/.profile"

