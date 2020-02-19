#%Module -*- tcl -*-
#
# ANSYS 2019 R3
#

# Updated for new ANSYS licence manager June 2013 BAA
# Updated for version ANSYS 14.5.7      June 2013 BAA
# Updated for ANSYS 15.0.7		Sept 2014 H.K.
# Updated for upgraded Legion software stack and ANSYS 16.1 - June 2015 - BAA
# Updated for ANSYS 17.0                Jan  2016 BAA
# Udated to remove the request to run setup_cfx.sh as running it now breaks 
# access to the licence manager - April 2016 - BAA
# Updated for ANSYS 17.2                Sept 2016 BAA
# Updated for ANSYS 18.0                Feb 2017 BAA
# Updated for coupled field analysis paths    Jan 2018 BAA
# Updated for ANSYS 19.1                May 2018 BAA
# Further updated with settings directories on Scratch and Ansys EM products
# support    June 2018
# Fix bug with creating ~/.config/Ansys settings directory when ~/.config
# doesn't exist    Oct 2018
# Updated for ANSYS 2019 R3 and included in beta modules  17th Oct 2019.
# Moved to main modules 19th December 2019
# Updated to add AUTODYN paths January 2020

lappend auto_path /shared/ucl/apps/modulelibs/UsefulModuleFunctions
package require modulefunctions 1.0

proc ModulesHelp { } {

    puts stderr "This module adds the ANSYS 2019 R3 Campus Agreement CFX/Fluent, EM etc products to your environment."
    puts stderr ""
    puts stderr "Please remember that if you run this in the batch system, you"
    puts stderr "can't use X-Windows output.  "
    puts stderr ""
    puts stderr "You SHOULD request licenses with  -ac app=cfx"
    puts stderr ""
}

proc appDirSetup { appDir } {

    set target "~/Scratch/[file tail $appDir]"
    set oldDir "$appDir.old"

    if { [catch {file type $appDir} type] } {	# appDir does not exist yet
	if { [modulefunctions::createDir $target] } {
	    return [modulefunctions::createSymlink $appDir $target]
	} else {
	    return false
	}
    }

    if { [modulefunctions::copySource $appDir $target] } {
	if { [string compare $type "link"] == 0 } { # is a symbolic link
	    return true
	} else {
	    if { [catch {file rename $appDir $oldDir}] } {
		puts stderr "Cannot move $appDir to $oldDir:"
		puts stderr "    $err"
		return false
	    }
	    return [modulefunctions::createSymlink $appDir $target]
	}
    } else {
	return false
    }
}

module-whatis "Adds Ansys CFX/Fluent, EM etc to your environment"

conflict ansys

# For ANSYS Electromagnetics products
prereq   giflib/5.1.1

set          prefix	/shared/ucl/apps/ANSYS/2019.R3

prepend-path PATH       $prefix/shared_files/licensing/lic_admin
prepend-path PATH      	$prefix/v195/CFX/bin
prepend-path PATH	$prefix/v195/fluent/bin
prepend-path PATH       $prefix/v195/TurboGrid/bin
prepend-path PATH       $prefix/v195/Framework/bin/Linux64
prepend-path PATH      	$prefix/ucl/bin

# Added for ANSYS 19.1 to add products like ANSYS Mechanical APDL 
prepend-path PATH       $prefix/v195/ansys/bin

# Added for coupled field analysis
prepend-path PATH       $prefix/v195/aisol
prepend-path PATH       $prefix/v195/aisol/bin/linx64
prepend-path PATH       $prefix/v195/aisol/CommonFiles/linx64

# Added for ANSYS Autodyn installed with 2019.R3
prepend-path PATH       $prefix/v195/autodyn/bin
prepend-path PATH       $prefix/v195/autodyn/bin/linx64
prepend-path LD_LIBRARY_PATH $prefix/v195/autodyn/lib/linx64

prepend-path LM_LICENSE_FILE	1055@lic-ansys.ucl.ac.uk

setenv ANSYS_ROOT      	$prefix
setenv ANSYS195_DIR	$prefix/v195/ansys
setenv ANSYSLIC_DIR     $prefix/shared_files/licensing
setenv ANSYS195_PRODUCT aa_mcad
setenv ANSYS_LOCK      	ON
setenv ANSYS195_WORKING_DIRECTORY ~/Scratch/ansys_work
setenv ANSBROWSER      /usr/bin/firefox

set AnsysDirLoc "~/.config"
set AnsysDir "~/Scratch/.config/Ansys"

# For Ansys Fluent
set FLRECENT "~/.flrecent"


# For ANSYS Electromagnetics products
prepend-path PATH            $prefix/AnsysEM/AnsysEM19.1/Linux64
prepend-path LD_LIBRARY_PATH $prefix/AnsysEM/AnsysEM19.1/Linux64
setenv ANSYSEM_DIR           $prefix/AnsysEM/AnsysEM19.1
setenv ECAD_TRANSLATORS_INSTALL_DIR   $prefix/AnsysEM/LayoutIntegrations19.1/Linux64

# set $TMPDIR to /tmp if not set (ie on login nodes)
if { ! [info exists ::env(TMPDIR) ] } {
  setenv TMPDIR /tmp
}

setenv FL_TMPDIR $::env(TMPDIR)

set AnsysEMDir "~/Ansoft"
set mwDir "~/.mw"

if { [modulefunctions::isModuleLoad] } {
    if { ! [appDirSetup $AnsysDirLoc] } {
	puts stderr ""
	puts stderr "**** error: setting up ~/.config directory failed."
	puts stderr ""
	puts stderr "Note: you must load the ANSYS module at least once from a login node before"
	puts stderr "running any jobs or qrsh sessions on the cluster."
	puts stderr ""
    }
    if { ! [modulefunctions::createDir $AnsysDir] } {
	puts stderr ""
	puts stderr "**** error: setting up ANSYS products user directory failed."
	puts stderr ""
	puts stderr "Note: you must load the ANSYS module at least once from a login node before"
	puts stderr "running any jobs or qrsh sessions on the cluster."
	puts stderr ""
    }
    if { ! [appDirSetup $FLRECENT] } {
	puts stderr ""
	puts stderr "**** error: setting up ANSYS/FLuent userfile .flrecent."
	puts stderr ""
	puts stderr "Note: you must load the ANSYS module at least once from a login node before"
	puts stderr "running any jobs or qrsh sessions on the cluster."
	puts stderr ""
    }
    if { ! [appDirSetup $AnsysEMDir] } {
	puts stderr ""
	puts stderr "**** error: setting up ANSYS Electromagnetics products user directory failed."
	puts stderr ""
	puts stderr "Note: you must load the ANSYS module at least once from a login node before"
	puts stderr "running any jobs or qrsh sessions on the cluster."
	puts stderr ""
    }
    if { ! [appDirSetup $mwDir] } {
	puts stderr ""
	puts stderr "**** error: setting up ANSYS Electromagnetics products .mw directory failed."
	puts stderr ""
	puts stderr "Note: you must load the ANSYS module at least once from a login node before"
	puts stderr "running any jobs or qrsh sessions on the cluster."
	puts stderr ""
    }
}

# Configure MPI fabric for Intel MPI as ANSYS is not using gerun
setenv I_MPI_FABRICS    shm:ofa
setenv I_MPI_FALLBACK   1

# Set IBM Platform MPI variables for correct fabric choice - definitely required
# for Myriad.

setenv MPI_IC_ORDER upapl:tcp
