#!/bin/sh
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/dogtag/acceptance/cli-tests/pki-tks-group-cli
#   Description: PKI tks-group-cli-tks-group-member-find CLI tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following pki cli commands needs to be tested:
#  pki-tks-group-cli-tks-group-member-find    Find group members.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Authors: Roshni Pattath <rpattath@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2013 Red Hat, Inc. All rights reserved.
#
#   This copyrighted material is made available to anyone wishing
#   to use, modify, copy, or redistribute it subject to the terms
#   and conditions of the GNU General Public License version 2.
#
#   This program is distributed in the hope that it will be
#   useful, but WITHOUT ANY WARRANTY; without even the implied
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#   PURPOSE. See the GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public
#   License along with this program; if not, write to the Free
#   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
#   Boston, MA 02110-1301, USA.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. /opt/rhqa_pki/rhcs-shared.sh
. /opt/rhqa_pki/pki-cert-cli-lib.sh
. /opt/rhqa_pki/env.sh
######################################################################################
#create_role_users.sh should be first executed prior to pki-tks-group-cli-tks-group-member-find.sh
######################################################################################

########################################################################
# Test Suite Globals
########################################################################

run_pki-tks-group-cli-tks-group-member-find_tests(){
	rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-001: Create temporary directory"
                rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
                rlRun "pushd $TmpDir"
        rlPhaseEnd
get_topo_stack $MYROLE $TmpDir/topo_file
        local TKS_INST=$(cat $TmpDir/topo_file | grep MY_TKS | cut -d= -f2)
        tks_instance_created="False"
        if [ "$TOPO9" = "TRUE" ] ; then
                prefix=$TKS_INST
                tks_instance_created=$(eval echo \$${prefix}_INSTANCE_CREATED_STATUS)
        elif [ "$MYROLE" = "MASTER" ] ; then
                prefix=TKS1
                tks_instance_created=$(eval echo \$${prefix}_INSTANCE_CREATED_STATUS)
        else
                prefix=$MYROLE
                tks_instance_created=$(eval echo \$${prefix}_INSTANCE_CREATED_STATUS)
        fi
if [ "$tks_instance_created" = "TRUE" ];  then
subsystemId=$1
SUBSYSTEM_TYPE=$2
MYROLE=$3
caId=$4
CA_HOST=$5
TKS_HOST=$(eval echo \$${MYROLE})
TKS_PORT=$(eval echo \$${subsystemId}_UNSECURE_PORT)
CA_PORT=$(eval echo \$${caId}_UNSECURE_PORT)
eval ${subsystemId}_adminV_user=${subsystemId}_adminV
eval ${subsystemId}_adminR_user=${subsystemId}_adminR
eval ${subsystemId}_adminE_user=${subsystemId}_adminE
eval ${subsystemId}_adminUTCA_user=${subsystemId}_adminUTCA
eval ${subsystemId}_agentV_user=${subsystemId}_agentV
eval ${subsystemId}_agentR_user=${subsystemId}_agentR
eval ${subsystemId}_agentE_user=${subsystemId}_agentE
eval ${subsystemId}_auditV_user=${subsystemId}_auditV
eval ${subsystemId}_operatorV_user=${subsystemId}_operatorV
local TEMP_NSS_DB="$TmpDir/nssdb"
local TEMP_NSS_DB_PASSWD="redhat123"
local cert_info="$TmpDir/cert_info"
#Available groups tks-group-find
        groupid1="Token Key Service Manager Agents"
        groupid2="Subsystem Group"
        groupid3="Trusted Managers"
        groupid4="Administrators"
        groupid5="Auditors"
        groupid6="ClonedSubsystems"
	rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-002: pki tks-group-member-find --help configuration test"
                rlRun "pki tks-group-member-find --help > $TmpDir/pki_tks_group_member_find_cfg.out 2>&1" \
                        0 \
                       "pki tks-group-member-find --help"
                rlAssertGrep "usage: tks-group-member-find <Group ID> \[FILTER\] \[OPTIONS...\]" "$TmpDir/pki_tks_group_member_find_cfg.out"
                rlAssertGrep "\--help            Show help options" "$TmpDir/pki_tks_group_member_find_cfg.out"
                rlAssertGrep "\--size <size>     Page size" "$TmpDir/pki_tks_group_member_find_cfg.out"
                rlAssertGrep "\--start <start>   Page start" "$TmpDir/pki_tks_group_member_find_cfg.out"
        rlPhaseEnd

	rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-003: pki tks-group-member-find configuration test"
                rlRun "pki tks-group-member-find > $TmpDir/pki_tks_group_member_find_2_cfg.out 2>&1" \
                       255 \
                       "pki tks-group-member-find"
                rlAssertGrep "Error: Incorrect number of arguments specified." "$TmpDir/pki_tks_group_member_find_2_cfg.out"
                rlAssertGrep "usage: tks-group-member-find <Group ID> \[FILTER\] \[OPTIONS...\]" "$TmpDir/pki_tks_group_member_find_2_cfg.out"
                rlAssertGrep "\--help            Show help options" "$TmpDir/pki_tks_group_member_find_2_cfg.out"
                rlAssertGrep "\--size <size>     Page size" "$TmpDir/pki_tks_group_member_find_2_cfg.out"
                rlAssertGrep "\--start <start>   Page start" "$TmpDir/pki_tks_group_member_find_2_cfg.out"
        rlPhaseEnd
 
        rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-004: Find tks-group-member when user is added to different groups"
                i=1
                while [ $i -lt 7 ] ; do
                       rlLog "pki -d $CERTDB_DIR \
				   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                                   tks-user-add --fullName=\"fullNameu$i\" u$i "
                       rlRun "pki -d $CERTDB_DIR \
				   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                                   tks-user-add --fullName=\"fullNameu$i\" u$i > $TmpDir/pki-tks-group-member-find-user-find-00$i.out" \
                                   0 \
                                   "Adding user u$i"
                        rlAssertGrep "Added user \"u$i\"" "$TmpDir/pki-tks-group-member-find-user-find-00$i.out"
                        rlAssertGrep "User ID: u$i" "$TmpDir/pki-tks-group-member-find-user-find-00$i.out"
                        rlAssertGrep "Full name: fullNameu$i" "$TmpDir/pki-tks-group-member-find-user-find-00$i.out"
                        rlLog "Adding the user to a group"
                        eval gid=\$groupid$i
                        rlLog "pki -d $CERTDB_DIR \
				    -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                                    tks-group-member-add \"$gid\" u$i"
                        rlRun "pki -d $CERTDB_DIR \
				    -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                                     tks-group-member-add \"$gid\" u$i > $TmpDir/pki-tks-group-member-find-groupadd-00$i.out" \
                                     0 \
                                     "Adding user u$i to group \"$gid\""
                        rlAssertGrep "Added group member \"u$i\"" "$TmpDir/pki-tks-group-member-find-groupadd-00$i.out"
                        rlAssertGrep "User: u$i" "$TmpDir/pki-tks-group-member-find-groupadd-00$i.out"
                        rlLog "Check if the user is added to the group"
                        rlRun "pki -d $CERTDB_DIR \
				    -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                                    tks-group-member-find \"$gid\" > $TmpDir/pki-tks-group-member-find-groupadd-find-00$i.out" \
                                    0 \
                                    "Find group-members with group \"$gid\""
			rlAssertGrep "User: u$i" "$TmpDir/pki-tks-group-member-find-groupadd-find-00$i.out"

                        let i=$i+1
                done
        rlPhaseEnd

	rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-005: Find tks-group-member when the same user is added to many groups"
                rlRun "pki -d $CERTDB_DIR \
			    -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                            tks-user-add --fullName=\"fullName_userall\" userall > $TmpDir/pki-tks-group-member-find-user-find-userall-001.out" \
                            0 \
                            "Adding user userall"
                rlAssertGrep "Added user \"userall\"" "$TmpDir/pki-tks-group-member-find-user-find-userall-001.out"
                rlAssertGrep "User ID: userall" "$TmpDir/pki-tks-group-member-find-user-find-userall-001.out"
                rlAssertGrep "Full name: fullName_userall" "$TmpDir/pki-tks-group-member-find-user-find-userall-001.out"
                rlLog "Adding the user to all the groups"
                i=1
                while [ $i -lt 7 ] ; do
                        eval gid=\$groupid$i
                        rlLog "pki -d $CERTDB_DIR \
				    -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                                    tks-group-member-add \"$gid\" userall"
                        rlRun "pki -d $CERTDB_DIR \
				    -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                                    tks-group-member-add \"$gid\" userall > $TmpDir/pki-tks-group-member-find-groupadd-userall-00$i.out" \
                                    0 \
                                    "Adding user userall to group \"$gid\""
                        rlAssertGrep "Added group member \"userall\"" "$TmpDir/pki-tks-group-member-find-groupadd-userall-00$i.out"
                        rlAssertGrep "User: userall" "$TmpDir/pki-tks-group-member-find-groupadd-userall-00$i.out"
                        rlLog "Check if the user is added to the group"
                        rlRun "pki -d $CERTDB_DIR \
				    -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                                    tks-group-member-find \"$gid\" > $TmpDir/pki-tks-group-member-find-groupadd-find-userall-00$i.out" \
                                    0 \
                                    "Find user membership to group \"$gid\""
                        rlAssertGrep "User: userall" "$TmpDir/pki-tks-group-member-find-groupadd-find-userall-00$i.out"

                        let i=$i+1
                done
        rlPhaseEnd
	
	rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-006: Find tks-group-member when many users are added to one group"
		i=1
		rlRun "pki -d $CERTDB_DIR \
				    -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                                   tks-group-add --description=\"Test group\" group1 > $TmpDir/pki-tks-group-member-find-groupadd-006.out" \
                                   0 \
                                   "Adding group group1"
                        rlAssertGrep "Added group \"group1\"" "$TmpDir/pki-tks-group-member-find-groupadd-006.out"
                        rlAssertGrep "Group ID: group1" "$TmpDir/pki-tks-group-member-find-groupadd-006.out"
                        rlAssertGrep "Description: Test group" "$TmpDir/pki-tks-group-member-find-groupadd-006.out"
                while [ $i -lt 15 ] ; do
                       rlLog "pki -d $CERTDB_DIR \
				   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                                   tks-user-add --fullName=\"fullNameuser$i\" user$i "
                       rlRun "pki -d $CERTDB_DIR \
				   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                                   tks-user-add --fullName=\"fullNameuser$i\" user$i > $TmpDir/pki-tks-group-member-find-useradd-00$i.out" \
                                   0 \
                                   "Adding user user$i"
                        rlAssertGrep "Added user \"user$i\"" "$TmpDir/pki-tks-group-member-find-useradd-00$i.out"
                        rlAssertGrep "User ID: user$i" "$TmpDir/pki-tks-group-member-find-useradd-00$i.out"
                        rlAssertGrep "Full name: fullNameuser$i" "$TmpDir/pki-tks-group-member-find-useradd-00$i.out"
			rlLog "Adding user user$i to group1"
			rlRun "pki -d $CERTDB_DIR \
				    -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                                   tks-group-member-add group1 user$i > $TmpDir/pki-tks-group-member-find-group-member-add-00$i.out" \
                                   0 \
                                   "Adding user user$i"
                        rlAssertGrep "Added group member \"user$i\"" "$TmpDir/pki-tks-group-member-find-group-member-add-00$i.out"
                        rlAssertGrep "User: user$i" "$TmpDir/pki-tks-group-member-find-group-member-add-00$i.out"
			let i=$i+1
		done
		let i=$i-1
		rlLog "Find group members of group1"
                rlRun "pki -d $CERTDB_DIR \
			    -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                            tks-group-member-find group1 > $TmpDir/pki-tks-group-member-find-group1-006.out" \
                             0 \
                            "Find users added to group \"$gid\""
                rlAssertGrep "$i entries matched" "$TmpDir/pki-tks-group-member-find-group1-006.out"
                rlAssertGrep "Number of entries returned $i" "$TmpDir/pki-tks-group-member-find-group1-006.out"			
                i=1
                while [ $i -lt 15 ] ; do
			rlAssertGrep "User: user$i" "$TmpDir/pki-tks-group-member-find-group1-006.out"
                        let i=$i+1
                done
        rlPhaseEnd

        rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-007: Find tks-group-member of a user from the 6th position (start=5)"
		rlRun "pki -d $CERTDB_DIR \
			    -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                            tks-group-member-find group1 --start=5 > $TmpDir/pki-tks-group-member-find-groupadd-find-start-001.out" \
                            0 \
                            "Checking user added to group"
		rlAssertGrep "14 entries matched" "$TmpDir/pki-tks-group-member-find-groupadd-find-start-001.out"
                rlAssertGrep "User: user6" "$TmpDir/pki-tks-group-member-find-groupadd-find-start-001.out"
		rlAssertGrep "User: user7" "$TmpDir/pki-tks-group-member-find-groupadd-find-start-001.out"
		rlAssertGrep "User: user8" "$TmpDir/pki-tks-group-member-find-groupadd-find-start-001.out"
		rlAssertGrep "User: user9" "$TmpDir/pki-tks-group-member-find-groupadd-find-start-001.out"
		rlAssertGrep "User: user10" "$TmpDir/pki-tks-group-member-find-groupadd-find-start-001.out"
		rlAssertGrep "User: user11" "$TmpDir/pki-tks-group-member-find-groupadd-find-start-001.out"
		rlAssertGrep "User: user12" "$TmpDir/pki-tks-group-member-find-groupadd-find-start-001.out"
		rlAssertGrep "User: user13" "$TmpDir/pki-tks-group-member-find-groupadd-find-start-001.out"
		rlAssertGrep "User: user14" "$TmpDir/pki-tks-group-member-find-groupadd-find-start-001.out"
                rlAssertGrep "Number of entries returned 9" "$TmpDir/pki-tks-group-member-find-groupadd-find-start-001.out"
	rlPhaseEnd

        rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-008: Find all group members of a group (start=0)"
                rlRun "pki -d $CERTDB_DIR \
			   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                            tks-group-member-find group1 --start=0 > $TmpDir/pki-tks-group-member-find-groupadd-find-start-002.out" \
                            0 \
                            "Checking group members of a group "
                rlAssertGrep "14 entries matched" "$TmpDir/pki-tks-group-member-find-groupadd-find-start-002.out"
		i=1
		while [ $i -lt 15 ] ; do
	       		eval uid=user$i
			rlAssertGrep "User: $uid" "$TmpDir/pki-tks-group-member-find-groupadd-find-start-002.out"
			let i=$i+1
		done
                rlAssertGrep "Number of entries returned 14" "$TmpDir/pki-tks-group-member-find-groupadd-find-start-002.out"
        rlPhaseEnd

        rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-009: Find group members when page start is negative (start=-1)"
		command="pki -d $CERTDB_DIR -n $(eval echo \$${subsystemId}_adminV_user) -c $CERTDB_DIR_PASSWORD -h $TKS_HOST -p $TKS_PORT tks-group-member-find group1 --start=-1"
		errmsg="--start option should have argument greater than 0"
		errorcode=255
		rlRun "verifyErrorMsg \"$command\" \"$errmsg\" \"$errorcode\"" 0 "group-member-find should fail if start is less than 0"
		rlLog " FAIL: https://fedorahosted.org/pki/ticket/1068"
		rlLog "FAIL: https://fedorahosted.org/pki/ticket/929"
        rlPhaseEnd

        rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-010: Find group members when page start greater than available number of groups (start=15)"
		rlRun "pki -d $CERTDB_DIR \
			   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                            tks-group-member-find group1 --start=15 > $TmpDir/pki-tks-group-member-find-groupadd-find-start-004.out" \
                            0 \
                            "Checking group members of a group"
                rlAssertGrep "14 entries matched" "$TmpDir/pki-tks-group-member-find-groupadd-find-start-004.out"
                rlAssertGrep "Number of entries returned 0" "$TmpDir/pki-tks-group-member-find-groupadd-find-start-004.out"
        rlPhaseEnd

        rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-011: Should not be able to find group members when page start is non integer"
		command="pki -d $CERTDB_DIR -n $(eval echo \$${subsystemId}_adminV_user) -c $CERTDB_DIR_PASSWORD -h $TKS_HOST -p $TKS_PORT tks-group-member-find group1 --start=a"
		errmsg="NumberFormatException: For input string: \"a\""
		errorcode=255
		rlRun "verifyErrorMsg \"$command\" \"$errmsg\" \"$errorcode\"" 0 "Should not be able to find group members when page start is non integer"
        rlPhaseEnd

        rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-012: Find group member when page size is 0 (size=0)"
		rlRun "pki -d $CERTDB_DIR \
			   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                            tks-group-member-find group1 --size=0 > $TmpDir/pki-tks-group-member-find-groupadd-find-size-006.out" 0 \
                            "tks-group_member-find with size parameter as 0"
                rlAssertGrep "14 entries matched" "$TmpDir/pki-tks-group-member-find-groupadd-find-size-006.out"
		rlAssertGrep "Number of entries returned 0" "$TmpDir/pki-tks-group-member-find-groupadd-find-size-006.out"
        rlPhaseEnd

        rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-013: Find group members when page size is 1 (size=1)"
		rlRun "pki -d $CERTDB_DIR \
			   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                            tks-group-member-find group1 --size=1 > $TmpDir/pki-tks-group-member-find-groupadd-find-size-007.out" 0 \
                            "tks-group_member-find with size parameter as 1"
                rlAssertGrep "14 entries matched" "$TmpDir/pki-tks-group-member-find-groupadd-find-size-007.out"
                rlAssertGrep "User: user1" "$TmpDir/pki-tks-group-member-find-groupadd-find-size-007.out"
                rlAssertGrep "Number of entries returned 1" "$TmpDir/pki-tks-group-member-find-groupadd-find-size-007.out"
        rlPhaseEnd

        rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-014: Find group members when page size is 15 (size=15)"
                rlRun "pki -d $CERTDB_DIR \
			   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                            tks-group-member-find group1 --size=15 > $TmpDir/pki-tks-group-member-find-groupadd-find-size-009.out" 0 \
                            "tks-group_member-find with size parameter as 15"
		rlAssertGrep "14 entries matched" "$TmpDir/pki-tks-group-member-find-groupadd-find-size-009.out"
		i=1
                while [ $i -lt 15 ] ; do
                	eval uid=user$i
                        rlAssertGrep "User: $uid" "$TmpDir/pki-tks-group-member-find-groupadd-find-size-009.out"
                        let i=$i+1
                done
                rlAssertGrep "Number of entries returned 14" "$TmpDir/pki-tks-group-member-find-groupadd-find-size-009.out"
        rlPhaseEnd

        rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-015: Find group members when page size greater than available number of groups (size=100)"
		rlRun "pki -d $CERTDB_DIR \
			   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                            tks-group-member-find group1 --size=100 > $TmpDir/pki-tks-group-member-find-groupadd-find-size-0010.out"  0 \
                            "tks-group_member-find with size parameter as 100"
                rlAssertGrep "14 entries matched" "$TmpDir/pki-tks-group-member-find-groupadd-find-size-0010.out"
		i=1
                while [ $i -lt 15 ] ; do
               		eval uid=user$i
                        rlAssertGrep "User: $uid" "$TmpDir/pki-tks-group-member-find-groupadd-find-size-0010.out"
                        let i=$i+1
                done
                rlAssertGrep "Number of entries returned 14" "$TmpDir/pki-tks-group-member-find-groupadd-find-size-0010.out"
        rlPhaseEnd

        rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-016: Find group-member when page size is negative (size=-1)"
		command="pki -d $CERTDB_DIR -n $(eval echo \$${subsystemId}_adminV_user) -c $CERTDB_DIR_PASSWORD -h $TKS_HOST -p $TKS_PORT tks-group-member-find group1 --size=-1"
		errmsg="--size option should have argument greater than 0"
		errorcode=255
		rlRun "verifyErrorMsg \"$command\" \"$errmsg\" \"$errorcode\"" 0 "tks-group-member-find should fail if size is less than 0"
		rlLog "FAIL: https://fedorahosted.org/pki/ticket/861"
        rlPhaseEnd

        rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-017: Should not be able to find group members when page size is non integer"
		command="pki -d $CERTDB_DIR -n $(eval echo \$${subsystemId}_adminV_user) -c $CERTDB_DIR_PASSWORD -h $TKS_HOST -p $TKS_PORT tks-group-member-find group1 --size=a"
		errmsg="NumberFormatException: For input string: \"a\""
		errorcode=255
		rlRun "verifyErrorMsg \"$command\" \"$errmsg\" \"$errorcode\"" 0 "String cannot be used as input to size parameter "
        rlPhaseEnd

	rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-018: Find group members with -t tks option"
		rlLog "Executing: pki -d $CERTDB_DIR \
			   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                           -t tks \
                            tks-group-member-find group1 --size=5"
		rlRun "pki -d $CERTDB_DIR \
			   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                           -t tks \
                            tks-group-member-find group1 --size=5 > $TmpDir/pki-tks-group-member-find-018.out" \
		            0 \
                            "Find tks-group-member with -t tks option"
		rlAssertGrep "14 entries matched" "$TmpDir/pki-tks-group-member-find-018.out"
		i=1
                while [ $i -lt 5 ] ; do
                        eval uid=user$i
                        rlAssertGrep "User: $uid" "$TmpDir/pki-tks-group-member-find-018.out"
                        let i=$i+1
                done
        	rlAssertGrep "Number of entries returned 5" "$TmpDir/pki-tks-group-member-find-018.out"
	rlPhaseEnd

	rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-019: Find group members with page start and page size option"
		rlLog "pki -d $CERTDB_DIR \
			   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                            tks-group-member-find group1 --start=6 --size=5"
                rlRun "pki -d $CERTDB_DIR \
			   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                            tks-group-member-find group1 --start=6 --size=5 > $TmpDir/pki-tks-group-member-find-019.out" \
                            0 \
                            "Find group members with page start and page size option"
                rlAssertGrep "14 entries matched" "$TmpDir/pki-tks-group-member-find-019.out"
		i=7
                while [ $i -lt 12 ] ; do
                        eval uid=user$i
                        rlAssertGrep "User: $uid" "$TmpDir/pki-tks-group-member-find-019.out"
                        let i=$i+1
                done
                rlAssertGrep "Number of entries returned 5" "$TmpDir/pki-tks-group-member-find-019.out"
        rlPhaseEnd

	rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-020: Find group members with --size more than maximum possible value"
		randhex=$(openssl rand -hex 12 |  perl -p -e 's/\n//')
                randhex_covup=${randhex^^}
                maximum_check=$(echo "ibase=16;$randhex_covup"|bc)
		command="pki -d $CERTDB_DIR -n $(eval echo \$${subsystemId}_adminV_user) -c $CERTDB_DIR_PASSWORD -h $TKS_HOST -p $TKS_PORT tks-group-member-find group1 --size=$maximum_check"
		errmsg="NumberFormatException: For input string: \"$maximum_check\""
		errorcode=255
		rlRun "verifyErrorMsg \"$command\" \"$errmsg\" \"$errorcode\"" 0 "An exception should be thrown if size has a value greater than the maximum possible"
	rlPhaseEnd

	rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-021: Find  group members with --start more than maximum possible value"
		randhex=$(openssl rand -hex 12 |  perl -p -e 's/\n//')
                randhex_covup=${randhex^^}
                maximum_check=$(echo "ibase=16;$randhex_covup"|bc)
		command="pki -d $CERTDB_DIR -n $(eval echo \$${subsystemId}_adminV_user) -c $CERTDB_DIR_PASSWORD -h $TKS_HOST -p $TKS_PORT tks-group-member-find group1 --start=$maximum_check"
                errmsg="NumberFormatException: For input string: \"$maximum_check\""
                errorcode=255
                rlRun "verifyErrorMsg \"$command\" \"$errmsg\" \"$errorcode\"" 0 "An exception should be thrown if start has a value greater than the maximum possible"
        rlPhaseEnd

	rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-022: Should not be able to tks-group-member-find using a revoked cert TKS_adminR"
                command="pki -d $CERTDB_DIR -n $(eval echo \$${subsystemId}_adminR_user) -c $CERTDB_DIR_PASSWORD -h $TKS_HOST -p $TKS_PORT tks-group-member-find group1 --start=0 --size=5"
		errmsg="PKIException: Unauthorized"
		errorcode=255
                rlRun "verifyErrorMsg \"$command\" \"$errmsg\" \"$errorcode\"" 0 "Should not be able to find group members using a revoked cert TKS_adminR"
		rlLog "PKI Ticket: https://fedorahosted.org/pki/ticket/1134"
	        rlLog "PKI Ticket: https://fedorahosted.org/pki/ticket/1182"
	rlPhaseEnd

	rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-023: Should not be able to group-member-find using an agent with revoked cert TKS_agentR"
		command="pki -d $CERTDB_DIR -n $(eval echo \$${subsystemId}_agentR_user) -c $CERTDB_DIR_PASSWORD -h $TKS_HOST -p $TKS_PORT tks-group-member-find group1 --start=0 --size=5"
		errmsg="PKIException: Unauthorized"
                errorcode=255
                rlRun "verifyErrorMsg \"$command\" \"$errmsg\" \"$errorcode\"" 0 "Should not be able to find tks-group-member using an agent with revoked cert TKS_agentR"
		rlLog "PKI Ticket: https://fedorahosted.org/pki/ticket/1134"
	        rlLog "PKI Ticket: https://fedorahosted.org/pki/ticket/1182"
	rlPhaseEnd

	rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-024: Should not be able to tks-group-member-find using a valid agent TKS_agentV user"
		command="pki -d $CERTDB_DIR -n $(eval echo \$${subsystemId}_agentV_user) -c $CERTDB_DIR_PASSWORD -h $TKS_HOST -p $TKS_PORT tks-group-member-find group1 --start=0 --size=5"
                errmsg="ForbiddenException: Authorization Error"
                errorcode=255
                rlRun "verifyErrorMsg \"$command\" \"$errmsg\" \"$errorcode\"" 0 "Should not be able to find group members using a valid agent TKS_agentV user cert"
	rlPhaseEnd

	rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-025: Should not be able to tks-group-member-find using admin user with expired cert TKS_adminE"
		rlRun "date --set='+2 days'" 0 "Set System date 2 days ahead"
       		rlRun "date"
		command="pki -d $CERTDB_DIR -n $(eval echo \$${subsystemId}_adminE_user) -c $CERTDB_DIR_PASSWORD -h $TKS_HOST -p $TKS_PORT tks-group-member-find group1 --start=0 --size=5"
                errmsg="ForbiddenException: Authorization Error"
                errorcode=255
                rlRun "verifyErrorMsg \"$command\" \"$errmsg\" \"$errorcode\"" 0 "Should not be able to find tks-group-member using a expired admin TKS_adminE user cert"
		rlLog "PKI Ticket::  https://fedorahosted.org/pki/ticket/962"
		rlRun "date --set='2 days ago'" 0 "Set System back to the present day"
	rlPhaseEnd

	rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-026: Should not be able to tks-group-member-find using TKS_agentE cert"
		rlRun "date --set='+2 days'" 0 "Set System date 2 days ahead"
                rlRun "date"
                command="pki -d $CERTDB_DIR -n $(eval echo \$${subsystemId}_agentE_user) -c $CERTDB_DIR_PASSWORD -h $TKS_HOST -p $TKS_PORT tks-group-member-find group1 --start=0 --size=5"
                errmsg="ForbiddenException: Authorization Error"
                errorcode=255
                rlRun "verifyErrorMsg \"$command\" \"$errmsg\" \"$errorcode\"" 0 "Should not be able to find group-member using a expired agent TKS_agentE user cert"
                rlLog "PKI Ticket::  https://fedorahosted.org/pki/ticket/962"
                rlRun "date --set='2 days ago'" 0 "Set System back to the present day"
        rlPhaseEnd

	rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-027: Should not be able to tks-group-member-find using TKS_auditV cert"
                command="pki -d $CERTDB_DIR -n $(eval echo \$${subsystemId}_auditV_user) -c $CERTDB_DIR_PASSWORD -h $TKS_HOST -p $TKS_PORT tks-group-member-find group1 --start=0 --size=5"
                errmsg="ForbiddenException: Authorization Error"
                errorcode=255
                rlRun "verifyErrorMsg \"$command\" \"$errmsg\" \"$errorcode\"" 0 "Should not be able to find group-member using a valid auditor TKS_auditV user cert"
        rlPhaseEnd

	rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-028: Should not be able to tks-group-member-find using TKS_operatorV cert"
                command="pki -d $CERTDB_DIR -n $(eval echo \$${subsystemId}_operatorV_user) -c $CERTDB_DIR_PASSWORD -h $TKS_HOST -p $TKS_PORT tks-group-member-find group1 --start=0 --size=5"
                errmsg="ForbiddenException: Authorization Error"
                errorcode=255
                rlRun "verifyErrorMsg \"$command\" \"$errmsg\" \"$errorcode\"" 0 "Should not be able to find group-members using a valid operator TKS_operatorV user cert"
        rlPhaseEnd

	rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-029: Should not be able to tks-group-member-find using role_user_UTCA cert"
                command="pki -d $UNTRUSTED_CERT_DB_LOCATION -n role_user_UTCA -c $UNTRUSTED_CERT_DB_PASSWORD -h $TKS_HOST -p $TKS_PORT tks-group-member-find group1 --start=0 --size=5"
                errmsg="PKIException: Unauthorized"
                errorcode=255
                rlRun "verifyErrorMsg \"$command\" \"$errmsg\" \"$errorcode\"" 0 "Should not be able to find tks-group-member using a untrusted TKS_adminUTCA user cert"
        rlPhaseEnd

	rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-030: Should not be able to tks-group-member-find using role_user_UTCA cert"
                command="pki -d $UNTRUSTED_CERT_DB_LOCATION -n role_user_UTCA -c $UNTRUSTED_CERT_DB_PASSWORD -h $TKS_HOST -p $TKS_PORT tks-group-member-find group1 --start=0 --size=5"
                errmsg="PKIException: Unauthorized"
                errorcode=255
                rlRun "verifyErrorMsg \"$command\" \"$errmsg\" \"$errorcode\"" 0 "Should not be able to find group-member using a untrusted TKS_agentUTCA user cert"
		rlLog "PKI Ticket::  https://fedorahosted.org/pki/ticket/962"
        rlPhaseEnd

	rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-031:Find group-member for group id with i18n characters"
                rlLog "pki -d $CERTDB_DIR \
			   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                            tks-user-add --fullName='u9' u9"
                rlRun "pki -d $CERTDB_DIR \
			   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                            tks-user-add --fullName='u9' u9" \
                            0 \
                            "Adding uid u9"
		rlLog "Create a group dadminist??asj???? with i18n characters"
                rlRun "pki -d $CERTDB_DIR \
			   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                            tks-group-add 'dadminist??asj????' --description \"Admininstartors in French\" 2>&1 > $TmpDir/pki-tks-group-member-add-groupadd-031_1.out" \
                            0 \
                            "Adding group dadminist??asj???? with i18n characters"
                rlAssertGrep "Added group \"dadminist??asj????\"" "$TmpDir/pki-tks-group-member-add-groupadd-031_1.out"
                rlAssertGrep "Group ID: dadminist??asj????" "$TmpDir/pki-tks-group-member-add-groupadd-031_1.out"
                rlAssertGrep "Description: Admininstartors in French" "$TmpDir/pki-tks-group-member-add-groupadd-031_1.out"
		rlLog "pki -d $CERTDB_DIR \
			   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                            tks-group-member-add \"dadminist??asj????\" u9"
                rlRun "pki -d $CERTDB_DIR \
			   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                           tks-group-member-add \"dadminist??asj????\" u9 > $TmpDir/pki-tks-group-member-find-groupadd-031_2.out" \
                            0 \
                            "Adding user u9 to group \"dadminist??asj????\""
                rlAssertGrep "Added group member \"u9\"" "$TmpDir/pki-tks-group-member-find-groupadd-031_2.out"
                rlAssertGrep "User: u9" "$TmpDir/pki-tks-group-member-find-groupadd-031_2.out"
                rlLog "Check if the user is added to the group"
                rlRun "pki -d $CERTDB_DIR \
			   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                            tks-group-member-find \"dadminist??asj????\" > $TmpDir/pki-tks-group-member-find-groupadd-find-031_3.out" \
                            0 \
                            "Find group-member u9 in \"dadminist??asj????\"" 
	           rlAssertGrep "1 entries matched" "$TmpDir/pki-tks-group-member-find-groupadd-find-031_3.out"
                rlAssertGrep "User: u9" "$TmpDir/pki-tks-group-member-find-groupadd-find-031_3.out"	
	rlPhaseEnd

	rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-032: Find tks-group-member - paging"
                i=1
                rlRun "pki -d $CERTDB_DIR \
			   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                                   tks-group-add --description=\"Test group\" group2 > $TmpDir/pki-tks-group-member-find-groupadd-034.out" \
                                   0 \
                                   "Adding group group2"
                        rlAssertGrep "Added group \"group2\"" "$TmpDir/pki-tks-group-member-find-groupadd-034.out"
                        rlAssertGrep "Group ID: group2" "$TmpDir/pki-tks-group-member-find-groupadd-034.out"
                        rlAssertGrep "Description: Test group" "$TmpDir/pki-tks-group-member-find-groupadd-034.out"
                while [ $i -lt 25 ] ; do
                       rlLog "pki -d $CERTDB_DIR \
				  -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                                   tks-user-add --fullName=\"fullNameuser$i\" userid$i "
                       rlRun "pki -d $CERTDB_DIR \
				  -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                                   tks-user-add --fullName=\"fullNameuser$i\" userid$i > $TmpDir/pki-tks-group-member-find-paging-useradd-00$i.out" \
                                   0 \
                                   "Adding user userid$i"
                        rlAssertGrep "Added user \"userid$i\"" "$TmpDir/pki-tks-group-member-find-paging-useradd-00$i.out"
                        rlAssertGrep "User ID: userid$i" "$TmpDir/pki-tks-group-member-find-paging-useradd-00$i.out"
                        rlAssertGrep "Full name: fullNameuser$i" "$TmpDir/pki-tks-group-member-find-paging-useradd-00$i.out"
                        rlLog "Adding user userid$i to group2"
                        rlRun "pki -d $CERTDB_DIR \
				   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                                   tks-group-member-add group2 userid$i > $TmpDir/pki-tks-group-member-find-paging-group-member-add-00$i.out" \
                                   0 \
                                   "Adding user userid$i"
                        rlAssertGrep "Added group member \"userid$i\"" "$TmpDir/pki-tks-group-member-find-paging-group-member-add-00$i.out"
                        rlAssertGrep "User: userid$i" "$TmpDir/pki-tks-group-member-find-paging-group-member-add-00$i.out"
                        let i=$i+1
                done
		let i=$i-1
                rlLog "Find group members of group2"
                rlRun "pki -d $CERTDB_DIR \
			   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                            tks-group-member-find group2 > $TmpDir/pki-tks-group-member-find-group1-034.out" \
                             0 \
                            "Find users added to group \"group2\""
                rlAssertGrep "$i entries matched" "$TmpDir/pki-tks-group-member-find-group1-034.out"
                rlAssertGrep "Number of entries returned 20" "$TmpDir/pki-tks-group-member-find-group1-034.out"
                i=1
                while [ $i -lt 20 ] ; do
                        rlAssertGrep "User: userid$i" "$TmpDir/pki-tks-group-member-find-group1-034.out"
                        let i=$i+1
                done
        rlPhaseEnd

        rlPhaseStartTest "pki_tks_group_cli_tks_group_member-find-cleanup-001: Deleting the temp directory, users and groups"
		
                #===Deleting users created using TKS_adminV cert===#
                i=1
                while [ $i -lt 7 ] ; do
                       rlRun "pki -d $CERTDB_DIR \
				  -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                                   tks-user-del  u$i > $TmpDir/pki-user-del-tks-group-member-find-user-del-tks-00$i.out" \
                                   0 \
                                   "Deleted user u$i"
                        rlAssertGrep "Deleted user \"u$i\"" "$TmpDir/pki-user-del-tks-group-member-find-user-del-tks-00$i.out"
                        let i=$i+1
                done
		rlRun "pki -d $CERTDB_DIR \
                                  -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                                   tks-user-del  u9 > $TmpDir/pki-user-del-tks-group-member-find-user-del-tks-007.out" \
                                   0 \
                                   "Deleted user u9"
                        rlAssertGrep "Deleted user \"u9\"" "$TmpDir/pki-user-del-tks-group-member-find-user-del-tks-007.out"
		i=1
		while [ $i -lt 15 ] ; do
                       rlRun "pki -d $CERTDB_DIR \
				  -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                                   tks-user-del  user$i > $TmpDir/pki-user-del-tks-group-member-find-user-del-tks-group1-00$i.out" \
                                   0 \
                                   "Deleted user user$i"
                        rlAssertGrep "Deleted user \"user$i\"" "$TmpDir/pki-user-del-tks-group-member-find-user-del-tks-group1-00$i.out"
                        let i=$i+1
                done
		i=1
		while [ $i -lt 25 ] ; do
                       rlRun "pki -d $CERTDB_DIR \
				  -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                                   tks-user-del  userid$i > $TmpDir/pki-user-del-tks-group-member-find-user-del-tks-group2-00$i.out" \
                                   0 \
                                   "Deleted user userid$i"
                        rlAssertGrep "Deleted user \"userid$i\"" "$TmpDir/pki-user-del-tks-group-member-find-user-del-tks-group2-00$i.out"
                        let i=$i+1
                done
		rlRun "pki -d $CERTDB_DIR \
			   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                            tks-user-del  userall > $TmpDir/pki-user-del-tks-group-member-find-user-del-tks-userall.out" \
                            0 \
                            "Deleted user userall"
                rlAssertGrep "Deleted user \"userall\"" "$TmpDir/pki-user-del-tks-group-member-find-user-del-tks-userall.out"
	

		#===Deleting groups created using TKS_adminV===#
                rlRun "pki -d $CERTDB_DIR \
			-n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                        tks-group-del 'group1' > $TmpDir/pki-user-del-tks-group1.out" \
                        0 \
                        "Deleting group group1"
                rlAssertGrep "Deleted group \"group1\"" "$TmpDir/pki-user-del-tks-group1.out"

		rlRun "pki -d $CERTDB_DIR \
			-n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
                        tks-group-del 'group2' > $TmpDir/pki-user-del-tks-group2.out" \
                        0 \
                        "Deleting group group2"
                rlAssertGrep "Deleted group \"group2\"" "$TmpDir/pki-user-del-tks-group2.out"


	        #===Deleting i18n group created using TKS_adminV cert===#
        	rlRun "pki -d $CERTDB_DIR \
			-n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TKS_HOST \
                    -p $TKS_PORT \
        	        tks-group-del 'dadminist??asj????' > $TmpDir/pki-user-del-tks-group-i18n_1.out" \
                	0 \
	                "Deleting group dadminist??asj????"
        	rlAssertGrep "Deleted group \"dadminist??asj????\"" "$TmpDir/pki-user-del-tks-group-i18n_1.out"

		#Delete temporary directory
		rlRun "popd"
		rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
	rlPhaseEnd
else
        rlPhaseStartCleanup "pki tks-group-member-find cleanup: Delete temp dir"
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
        rlLog "TKS subsystem is not installed"
        rlPhaseEnd
fi
}
