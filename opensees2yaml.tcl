###################################################
# File: Opensees2yaml.tcl
# Author: Hanlin Dong
# Create: 2019-05-07 14:48:46
# Version: 1.0
# Last update: 2020-04-10 21:12:27
# License: MIT License (https://opensource.org/licenses/MIT)
# (The latest version can be found on http://www.hanlindong.com/)
# Readme:
#     This script logs the opensees tcl model into a yaml file with the schema shown below.
# Usage:
#     First, import this file.
#         ```
#         source opensees2yaml.tcl
#         ```
#     Then, create a log file and call the fuction
#         ```
#         set f [open "opslog.txt" "w"]
#         puts $f [opensees2yaml 3]
#         close $f
#         ```
#     Then you can use the generated file in OpenSees online visualizer 
#     (http://www.hanlindong.com/tool/opensees-online-visualizer/)
# Change Log:
#   2019-04-07 14:48:46 v0.0
#     Create file.
#   2019-05-02 15:00:00 v0.1
#     Add functions on nodes, without displacement time-history.
#   2019-05-07 14:55:26 v0.2
#     Set a switch for the eigenvalue, in case that the current model do not has eigen value. In this case, set max_eigen to 0
#   2019-05-07 15:02:01 v0.3
#     Refactor. Let all the formal things (like indenting) concentrated on the assemble procedure.
#   2019-05-07 15:40:07 v0.4
#     Redesign the schema. Change array to object, using tags as keys directly. It's easier to use in javascript.
#   2019-08-18 16:37:36 v0.5
#     Add 3d element.
#   2019-09-06 14:10:45 v0.6
#     Rewrite readme.
#   2020-04-10 21:12:27 v1.0
#     Reorginaze the file. Beautify the code.
###################################################

# ARGS:
# max_eigen: the number of eigen values to be solved. If it is set to 0, no eigen value analysis is done.

# SCHEMA:
#
# nodes:
#   1:
#     coords: [1,1,1]
#     mass: [1,1,1,1,1,1]
#     eigen: 
#         - [1.1, 1.1, 1.1, 1.1, 1.1, 1.1]
#         - [2.2, 2.2, 2.2, 2.2, 2.2, 2.2]
# elements:
#   1:
#     connection: [1, 2]
#

puts "opensees2yaml version 1.0 successfully loaded ... (Author: Hanlin Dong. Licnese: MIT)"
proc opensees2yaml {{max_eigen 0}} {

# get eigen value
if {$max_eigen > 0} {
    puts "Eigen values:"
    puts [eigen $max_eigen]
} else {
    puts "Eigen value is not solved."
}

# get node tags
set node_tags [getNodeTags]
# get ndm and ndf
set ndm [llength [nodeCoord [lindex $node_tags 0]]]
set ndf [llength [nodeDisp [lindex $node_tags 0]]]
# log node coordinates
foreach node_tag $node_tags {
    # node coordinates
    set node_coord [nodeCoord $node_tag]
    set coordinates($node_tag) [format "\[%s\]" [join $node_coord ","]]
    # node mass
    if {$ndf == 6} {
        set masses($node_tag) [format "\[%f,%f,%f,%f,%f,%f\]" [nodeMass $node_tag 1] [nodeMass $node_tag 2] [nodeMass $node_tag 3] [nodeMass $node_tag 4] [nodeMass $node_tag 5] [nodeMass $node_tag 6]]
    } elseif {$ndf == 5} {
        set masses($node_tag) [format "\[%f,%f,%f,%f,%f\]" [nodeMass $node_tag 1] [nodeMass $node_tag 2] [nodeMass $node_tag 3] [nodeMass $node_tag 4] [nodeMass $node_tag 5]]
    } elseif {$ndf == 3} {
        set masses($node_tag) [format "\[%f,%f,%f\]" [nodeMass $node_tag 1] [nodeMass $node_tag 2] [nodeMass $node_tag 3]]
    } elseif {$ndf == 2} {
        set masses($node_tag) [format "\[%f,%f\]" [nodeMass $node_tag 1] [nodeMass $node_tag 2]]
    } elseif {$ndf == 1} {
        set masses($node_tag) [format "\[%f\]" [nodeMass $node_tag 1]]
    }
    # node eigen
    set eigen_list($node_tag) [list ]
    if {$max_eigen > 0} {
        for {set eigen 1} {$eigen <= $max_eigen} {incr eigen} {
            set vector [nodeEigenvector $node_tag $eigen]
            lappend eigen_list($node_tag) [format "\[%s\]" [join $vector ","]]
        }
    }
}


# get ele tags
set eleTags [getEleTags]
foreach eleTag $eleTags {
    # get ele connections
    set eleNode [eleNodes $eleTag]
    set connections($eleTag) [format "\[%s\]" [join $eleNode ","]]
}


# assemble
set yaml ""
append yaml [format "ndm: %d\n" $ndm]
append yaml [format "ndf: %d\n" $ndf]
append yaml "nodes:\n"
foreach node_tag $node_tags {
    append yaml "  $node_tag:\n"
    append yaml [format "    coords: %s\n" $coordinates($node_tag)]
    append yaml [format "    mass: %s\n" $masses($node_tag)]
    if {$max_eigen == 0} {
        append yaml "    eigen: ~\n"
    } else {
        append yaml "    eigen:\n"
        foreach eigen $eigen_list($node_tag) {
            append yaml [format "      - %s\n" $eigen]
        }
    }
}
append yaml "elements:\n"
foreach eleTag $eleTags {
    append yaml "  $eleTag:\n"
    append yaml [format "    connections: %s\n" $connections($eleTag)]
}
return $yaml
}