#!/bin/sh
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/dogtag/acceptance/cli-tests/pki-tps-group-cli
#   Description: PKI tps-group-add CLI tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following pki cli commands needs to be tested:
#  pki-tps-group-cli-tps-group-add    Add group to pki subsystems.
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
. /usr/share/beakerlib/beakerlib.sh
. /opt/rhqa_pki/rhcs-shared.sh
. /opt/rhqa_pki/pki-cert-cli-lib.sh
. /opt/rhqa_pki/env.sh

########################################################################
#create-role-users.sh should be first executed prior to pki-tps-group-cli-tps-group-add.sh
########################################################################

########################################################################
# Test Suite Globals
########################################################################
run_pki-tps-group-cli-tps-group-add_tests(){
#### Create Temporary directory ####    

     rlPhaseStartSetup "pki_tps_group_cli_tps_group_add-startup: Create temporary directory"
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
    rlPhaseEnd
subsystemId=$1
SUBSYSTEM_TYPE=$2
MYROLE=$3
caId=$4
get_topo_stack $MYROLE $TmpDir/topo_file
        local TPS_INST=$(cat $TmpDir/topo_file | grep MY_TPS | cut -d= -f2)
        tps_instance_created="False"
        if [ "$TOPO9" = "TRUE" ] ; then
                prefix=$TPS_INST
                tps_instance_created=$(eval echo \$${prefix}_INSTANCE_CREATED_STATUS)
        elif [ "$MYROLE" = "MASTER" ] ; then
                prefix=TPS1
                tps_instance_created=$(eval echo \$${prefix}_INSTANCE_CREATED_STATUS)
        else
                prefix=$MYROLE
                tps_instance_created=$(eval echo \$${prefix}_INSTANCE_CREATED_STATUS)
        fi
if [ "$tps_instance_created" = "TRUE" ];  then
TPS_HOST=$(eval echo \$${MYROLE})
TPS_PORT=$(eval echo \$${subsystemId}_UNSECURE_PORT)
CA_PORT=$(eval echo \$${caId}_UNSECURE_PORT)
eval ${subsystemId}_adminV_user=${subsystemId}_adminV
eval ${subsystemId}_adminR_user=${subsystemId}_adminR
eval ${subsystemId}_adminE_user=${subsystemId}_adminE
eval ${subsystemId}_adminUTCA_user=${subsystemId}_adminUTCA
eval ${subsystemId}_agentV_user=${subsystemId}_agentV
eval ${subsystemId}_agentR_user=${subsystemId}_agentR
eval ${subsystemId}_agentE_user=${subsystemId}_agentE
eval ${subsystemId}_officerV_user=${subsystemId}_officerV
eval ${subsystemId}_operatorV_user=${subsystemId}_operatorV
local TEMP_NSS_DB="$TmpDir/nssdb"
local TEMP_NSS_DB_PASSWD="redhat123"

	#### pki tps-group configuration test ####

     rlPhaseStartTest "pki_tps_group_cli-configtest: pki tps-group --help configuration test"
        rlRun "pki tps-group --help > $TmpDir/pki_tps_group_cfg.out 2>&1" \
               0 \
               "pki tps-group --help"
        rlAssertGrep "tps-group-find          Find groups" "$TmpDir/pki_tps_group_cfg.out"
        rlAssertGrep "tps-group-show          Show group" "$TmpDir/pki_tps_group_cfg.out"
        rlAssertGrep "tps-group-add           Add group" "$TmpDir/pki_tps_group_cfg.out"
        rlAssertGrep "tps-group-mod           Modify group" "$TmpDir/pki_tps_group_cfg.out"
        rlAssertGrep "tps-group-del           Remove group" "$TmpDir/pki_tps_group_cfg.out"
	rlAssertGrep "tps-group-member        Group member management commands" "$TmpDir/pki_tps_group_cfg.out"
        rlAssertNotGrep "Error: Invalid module \"tps-group---help\"." "$TmpDir/pki_tps_group_cfg.out"
     rlPhaseEnd

	#### pki tps-group-add configuration test ####

    rlPhaseStartTest "pki_tps_group_cli_tps_group_add-configtest: pki tps-group-add configuration test"
        rlRun "pki tps-group-add --help > $TmpDir/pki_tps_group_add_cfg.out 2>&1" \
               0 \
               "pki tps-group-add --help"
        rlAssertGrep "usage: tps-group-add <Group ID> \[OPTIONS...\]" "$TmpDir/pki_tps_group_add_cfg.out"
        rlAssertGrep "\--description <description>   Description" "$TmpDir/pki_tps_group_add_cfg.out"
        rlAssertGrep "\--help                        Show help options" "$TmpDir/pki_tps_group_add_cfg.out"
    rlPhaseEnd

     ##### Tests to add TPS groups using a user of admin group with a valid cert####
    rlPhaseStartTest "pki_tps_group_cli_tps_group_add-001: Add a group to TPS using TPS_adminV"
	group1=new_group1
	group_desc1="New Group1"
        rlLog "Executing: pki -d $CERTDB_DIR \
		    -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TPS_HOST \
                    -p $TPS_PORT \
		    tps-group-add --description=\"$group_desc1\" $group1"
        rlRun "pki -d $CERTDB_DIR \
		   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TPS_HOST \
                    -p $TPS_PORT \
		    tps-group-add --description=\"$group_desc1\" $group1 > $TmpDir/pki-tps-group-add-001.out" \
		    0 \
		    "Add group $group1 to TPS"
        rlAssertGrep "Added group \"$group1\"" "$TmpDir/pki-tps-group-add-001.out"
        rlAssertGrep "Group ID: $group1" "$TmpDir/pki-tps-group-add-001.out"
        rlAssertGrep "Description: $group_desc1" "$TmpDir/pki-tps-group-add-001.out"
    rlPhaseEnd

    rlPhaseStartTest "pki_tps_group_cli_tps_group_add-002:maximum length of group id"
	group2=$(openssl rand -hex 2048 |  perl -p -e 's/\n//')
        rlRun "pki -d $CERTDB_DIR \
		   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TPS_HOST \
                    -p $TPS_PORT \
                    tps-group-add --description=\"Test Group\" \"$group2\" > $TmpDir/pki-tps-group-add-001_1.out" \
                    0 \
                    "Added group using TPS_adminV with maximum group id length"
	actual_groupid_string=`cat $TmpDir/pki-tps-group-add-001_1.out | grep 'Group ID:' | xargs echo`
        expected_groupid_string="Group ID: $group2"                       
        if [[ $actual_groupid_string = $expected_groupid_string ]] ; then
                rlPass "Group ID: $group2 found"
        else
                rlFail "Group ID: $group2 not found"
        fi
        rlAssertGrep "Description: Test Group" "$TmpDir/pki-tps-group-add-001_1.out"
    rlPhaseEnd

    rlPhaseStartTest "pki_tps_group_cli_tps_group_add-003:Group id with # character"
	group3=abc#
        rlRun "pki -d $CERTDB_DIR \
		   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TPS_HOST \
                    -p $TPS_PORT \
		    tps-group-add --description test $group3 > $TmpDir/pki-tps-group-add-001_2.out" \
                    0 \
                    "Added group using TPS_adminV, group id with # character"
        rlAssertGrep "Added group \"$group3\"" "$TmpDir/pki-tps-group-add-001_2.out"
        rlAssertGrep "Group ID: $group3" "$TmpDir/pki-tps-group-add-001_2.out"
        rlAssertGrep "Description: test" "$TmpDir/pki-tps-group-add-001_2.out"
    rlPhaseEnd

    rlPhaseStartTest "pki_tps_group_cli_tps_group_add-004:Group id with $ character"
	group4=abc$
        rlRun "pki -d $CERTDB_DIR \
		   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TPS_HOST \
                    -p $TPS_PORT \
		    tps-group-add --description=test $group4 > $TmpDir/pki-tps-group-add-001_3.out" \
                    0 \
                    "Added group using TPS_adminV, group id with $ character"
        rlAssertGrep "Added group \"$group4\"" "$TmpDir/pki-tps-group-add-001_3.out"
        rlAssertGrep "Group ID: abc\\$" "$TmpDir/pki-tps-group-add-001_3.out"
        rlAssertGrep "Description: test" "$TmpDir/pki-tps-group-add-001_3.out"
    rlPhaseEnd

    rlPhaseStartTest "pki_tps_group_cli_tps_group_add-005:Group id with @ character"
	group5=abc@
        rlRun "pki -d $CERTDB_DIR \
		   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TPS_HOST \
                    -p $TPS_PORT \
                    tps-group-add --description=test $group5 > $TmpDir/pki-tps-group-add-001_4.out " \
                    0 \
                    "Added group using TPS_adminV, group id with @ character"
        rlAssertGrep "Added group \"$group5\"" "$TmpDir/pki-tps-group-add-001_4.out"
        rlAssertGrep "Group ID: $group5" "$TmpDir/pki-tps-group-add-001_4.out"
        rlAssertGrep "Description: test" "$TmpDir/pki-tps-group-add-001_4.out"
    rlPhaseEnd

    rlPhaseStartTest "pki_tps_group_cli_tps_group_add-006:Group id with ? character"
	group6=abc?
        rlRun "pki -d $CERTDB_DIR \
		   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TPS_HOST \
                    -p $TPS_PORT \
                    tps-group-add --description=test $group6 > $TmpDir/pki-tps-group-add-001_5.out " \
                    0 \
                    "Added group using TPS_adminV, group id with ? character"
        rlAssertGrep "Added group \"$group6\"" "$TmpDir/pki-tps-group-add-001_5.out"
        rlAssertGrep "Group ID: $group6" "$TmpDir/pki-tps-group-add-001_5.out"
        rlAssertGrep "Description: test" "$TmpDir/pki-tps-group-add-001_5.out"
    rlPhaseEnd

    rlPhaseStartTest "pki_tps_group_cli_tps_group_add-007:Group id as 0"
	group7=0
        rlRun "pki -d $CERTDB_DIR \
		   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TPS_HOST \
                    -p $TPS_PORT \
                    tps-group-add --description=test $group7 > $TmpDir/pki-tps-group-add-001_6.out " \
                    0 \
                    "Added group using TPS_adminV, group id 0"
        rlAssertGrep "Added group \"$group7\"" "$TmpDir/pki-tps-group-add-001_6.out"
        rlAssertGrep "Group ID: $group7" "$TmpDir/pki-tps-group-add-001_6.out"
        rlAssertGrep "Description: test" "$TmpDir/pki-tps-group-add-001_6.out"
    rlPhaseEnd

    rlPhaseStartTest "pki_tps_group_cli_tps_group_add-008:--description with maximum length"
	groupdesc=$(openssl rand -hex 2048 |  perl -p -e 's/\n//')
        rlRun "pki -d $CERTDB_DIR \
		   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TPS_HOST \
                    -p $TPS_PORT \
                    tps-group-add --description=\"$groupdesc\" g1 2>&1> $TmpDir/pki-tps-group-add-001_7.out" \
                    0 \
                    "Added group using TPS_adminV with maximum --description length"
        rlAssertGrep "Added group \"g1\"" "$TmpDir/pki-tps-group-add-001_7.out"
        rlAssertGrep "Group ID: g1" "$TmpDir/pki-tps-group-add-001_7.out"
        rlAssertGrep "Description: $groupdesc" "$TmpDir/pki-tps-group-add-001_7.out"
	actual_desc_string=`cat $TmpDir/pki-tps-group-add-001_7.out | grep Description: | xargs echo`
        expected_desc_string="Description: $groupdesc"
        if [[ $actual_desc_string = $expected_desc_string ]] ; then
                rlPass "Description: $groupdesc found"
        else
                rlFail "Description: $groupdesc not found"
        fi
    rlPhaseEnd

    rlPhaseStartTest "pki_tps_group_cli_tps_group_add-009:--desccription with maximum length and symbols"
	rand_groupdesc=$(openssl rand -base64 2048 |  perl -p -e 's/\n//')
        groupdesc=$(echo $rand_groupdesc | sed 's/\///g')
        rlRun "pki -d $CERTDB_DIR \
		   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TPS_HOST \
                    -p $TPS_PORT \
                    tps-group-add --description='$groupdesc' g2 > $TmpDir/pki-tps-group-add-001_8.out" \
                    0 \
                    "Added group using TPS_adminV with maximum --desc length and character symbols in it"
        rlAssertGrep "Added group \"g2\"" "$TmpDir/pki-tps-group-add-001_8.out"
        rlAssertGrep "Group ID: g2" "$TmpDir/pki-tps-group-add-001_8.out"
	actual_desc_string=`cat $TmpDir/pki-tps-group-add-001_8.out | grep Description: | xargs echo`
        expected_desc_string="Description: $groupdesc"
        if [[ $actual_desc_string = $expected_desc_string ]] ; then
                rlPass "Description: $groupdesc found"
        else
                rlFail "Description: $groupdesc not found"
        fi
    rlPhaseEnd


    rlPhaseStartTest "pki_tps_group_cli_tps_group_add-010: Add a duplicate group to TPS"
         command="pki -d $CERTDB_DIR -n $(eval echo \$${subsystemId}_adminV_user) -c $CERTDB_DIR_PASSWORD -h $TPS_HOST -p $TPS_PORT tps-group-add --description='Duplicate Group' $group1"
         errmsg="ConflictingOperationException: Entry already exists."
	 errorcode=255
	 rlRun "verifyErrorMsg \"$command\" \"$errmsg\" \"$errorcode\"" 0 "Verify expected error message - pki group-add should fail on an attempt to add a duplicate group"
    rlPhaseEnd

    rlPhaseStartTest "pki_tps_group_cli_tps_group_add-011: Add a group to TPS with -t option"
	desc="Test Group"
        rlLog "Executing: pki -d $CERTDB_DIR \
		   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TPS_HOST \
                    -p $TPS_PORT \
                   -t tps \
                    tps-group-add --description=\"$desc\" g3"

        rlRun "pki -d $CERTDB_DIR \
		   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TPS_HOST \
                    -p $TPS_PORT \
                   -t tps \
                    tps-group-add --description=\"$desc\"  g3 > $TmpDir/pki-tps-group-add-0011.out" \
                    0 \
                    "Add group g3"
        rlAssertGrep "Added group \"g3\"" "$TmpDir/pki-tps-group-add-0011.out"
        rlAssertGrep "Group ID: g3" "$TmpDir/pki-tps-group-add-0011.out"
        rlAssertGrep "Description: $desc" "$TmpDir/pki-tps-group-add-0011.out"
    rlPhaseEnd

    rlPhaseStartTest "pki_tps_group_cli_tps_group_add-012:  Add a group -- missing required option group id"
	command="pki -d $CERTDB_DIR -n $(eval echo \$${subsystemId}_adminV_user) -c $CERTDB_DIR_PASSWORD -h $TPS_HOST -p $TPS_PORT tps-group-add --description='$group1'"
	errmsg="Error: No Group ID specified."
	errorcode=255
	rlRun "verifyErrorMsg \"$command\" \"$errmsg\" \"$errorcode\"" 0 "Verify expected error message - Add Group -- missing required option group id"
    rlPhaseEnd

    rlPhaseStartTest "pki_tps_group_cli_tps_group_add-013:  Add a group -- missing required option --description"
	rlLog "pki -d $CERTDB_DIR -n $(eval echo \$${subsystemId}_adminV_user) -c $CERTDB_DIR_PASSWORD -h $TPS_HOST -p $TPS_PORT tps-group-add g7"
        rlRun "pki -d $CERTDB_DIR -n $(eval echo \$${subsystemId}_adminV_user) -c $CERTDB_DIR_PASSWORD -h $TPS_HOST -p $TPS_PORT tps-group-add g7 > $TmpDir/pki-tps-group-add-0013.out" 0 "Successfully added group without description option"
	rlAssertGrep "Added group \"g7\"" "$TmpDir/pki-tps-group-add-0013.out"
        rlAssertGrep "Group ID: g7" "$TmpDir/pki-tps-group-add-0013.out"
    rlPhaseEnd

   
        ##### Tests to add groups using revoked cert#####
    rlPhaseStartTest "pki_tps_group_cli_tps_group_add-014: Should not be able to add group using a revoked cert TPS_adminR"
	command="pki -d $CERTDB_DIR -n $(eval echo \$${subsystemId}_adminR_user) -c $CERTDB_DIR_PASSWORD -h $TPS_HOST -p $TPS_PORT tps-group-add --description='$desc' $group1"
	errmsg="PKIException: Unauthorized"
	errorcode=255
	rlRun "verifyErrorMsg \"$command\" \"$errmsg\" \"$errorcode\"" 0 "Verify expected error message - Add Group -- using a revoked admin cert TPS_adminR"
	rlLog "PKI Ticket: https://fedorahosted.org/pki/ticket/1134"
        rlLog "PKI Ticket: https://fedorahosted.org/pki/ticket/1182"
    rlPhaseEnd

    rlPhaseStartTest "pki_tps_group_cli_tps_group_add-015: Should not be able to add group using a agent with revoked cert TPS_agentR"
	command="pki -d $CERTDB_DIR -n $(eval echo \$${subsystemId}_agentR_user) -c $CERTDB_DIR_PASSWORD -h $TPS_HOST -p $TPS_PORT tps-group-add --description='$desc' $group1"
	errmsg="PKIException: Unauthorized"
	errorcode=255
	rlRun "verifyErrorMsg \"$command\" \"$errmsg\" \"$errorcode\"" 0 "Verify expected error message - Add Group -- using a revoked agent cert TPS_agentR"
	rlLog "PKI Ticket: https://fedorahosted.org/pki/ticket/1134"
        rlLog "PKI Ticket: https://fedorahosted.org/pki/ticket/1182"
    rlPhaseEnd


        ##### Tests to add groups using an agent user#####
    rlPhaseStartTest "pki_tps_group_cli_tps_group_add-016: Should not be able to add group using a valid agent TPS_agentV user"
	command="pki -d $CERTDB_DIR -n $(eval echo \$${subsystemId}_agentV_user) -c $CERTDB_DIR_PASSWORD -h $TPS_HOST -p $TPS_PORT tps-group-add --description='$desc' $group1"
	errmsg="ForbiddenException: Authorization Error"
	errorcode=255
	rlRun "verifyErrorMsg \"$command\" \"$errmsg\" \"$errorcode\"" 0 "Verify expected error message - Add Group -- using a valid agent cert TPS_agentV"
    rlPhaseEnd


    ##### Tests to add groups using expired cert#####
    rlPhaseStartTest "pki_tps_group_cli_tps_group_add-017: Should not be able to add group using admin user with expired cert TPS_adminE"
	rlRun "date --set='next day'" 0 "Set System date a day ahead"
                                rlRun "date --set='next day'" 0 "Set System date a day ahead"
                                rlRun "date"
	command="pki -d $CERTDB_DIR -n $(eval echo \$${subsystemId}_adminE_user) -c $CERTDB_DIR_PASSWORD -h $TPS_HOST -p $TPS_PORT tps-group-add --description='$desc' $group1"
	errmsg="ForbiddenException: Authorization Error"
	errorcode=255
	rlRun "verifyErrorMsg \"$command\" \"$errmsg\" \"$errorcode\"" 0 "Verify expected error message - Add Group -- using an expired admin cert TPS_adminE"
        rlLog "PKI Ticket::  https://fedorahosted.org/pki/ticket/962"
	rlRun "date --set='2 days ago'" 0 "Set System back to the present day"
    rlPhaseEnd

    rlPhaseStartTest "pki_tps_group_cli_tps_group_add-018: Should not be able to add group using TPS_agentE cert"
	rlRun "date --set='next day'" 0 "Set System date a day ahead"
                                rlRun "date --set='next day'" 0 "Set System date a day ahead"
                                rlRun "date"
	command="pki -d $CERTDB_DIR -n $(eval echo \$${subsystemId}_agentE_user) -c $CERTDB_DIR_PASSWORD -h $TPS_HOST -p $TPS_PORT tps-group-add --description='$desc' $group1"
	errmsg="ForbiddenException: Authorization Error"
        errorcode=255
        rlRun "verifyErrorMsg \"$command\" \"$errmsg\" \"$errorcode\"" 0 "Verify expected error message - Add Group -- using an expired agent cert TPS_agentE"
        rlLog "PKI Ticket::  https://fedorahosted.org/pki/ticket/962"
	rlRun "date --set='2 days ago'" 0 "Set System back to the present day"
    rlPhaseEnd

	##### Tests to add groups using officer users#####
    rlPhaseStartTest "pki_tps_group_cli_tps_group_add-019: Should not be able to add group using a TPS_officerV"
	command="pki -d $CERTDB_DIR -n $(eval echo \$${subsystemId}_officerV_user) -c $CERTDB_DIR_PASSWORD -h $TPS_HOST -p $TPS_PORT tps-group-add --description='$desc' $group1"
	errmsg="ForbiddenException: Authorization Error"
	errorcode=255
	rlRun "verifyErrorMsg \"$command\" \"$errmsg\" \"$errorcode\"" 0 "Verify expected error message - Add Group -- using a valid officer cert TPS_officerV"
	rlLog "PKI Ticket::  https://fedorahosted.org/pki/ticket/962"
    rlPhaseEnd

	##### Tests to add groups using operator user###
    rlPhaseStartTest "pki_tps_group_cli_tps_group_add-020: Should not be able to add group using a TPS_operatorV"
	command="pki -d $CERTDB_DIR -n $(eval echo \$${subsystemId}_operatorV_user) -c $CERTDB_DIR_PASSWORD -h $TPS_HOST -p $TPS_PORT tps-group-add --description='$desc' $group1"
	errmsg="ForbiddenException: Authorization Error"
	errorcode=255
	rlRun "verifyErrorMsg \"$command\" \"$errmsg\" \"$errorcode\"" 0 "Verify expected error message - Add Group -- using TPS_operatorV"
    rlPhaseEnd


	 ##### Tests to add groups using TPS_adminUTCA and TPS_agentUTCA  user's certificate will be issued by an untrusted CA user#####
    rlPhaseStartTest "pki_tps_group_cli_tps_group_add-021: Should not be able to add group using a cert created from a untrusted CA"
	command="pki -d $UNTRUSTED_CERT_DB_LOCATION -n role_user_UTCA -c $UNTRUSTED_CERT_DB_PASSWORD -h $TPS_HOST -p $TPS_PORT tps-group-add --description='$desc' $group1"
	errmsg="PKIException: Unauthorized"
	errorcode=255
	rlRun "verifyErrorMsg \"$command\" \"$errmsg\" \"$errorcode\"" 0 "Verify expected error message - Add Group -- using TPS_adminUTCA"
    rlPhaseEnd

    rlPhaseStartTest "pki_tps_group_cli_tps_group_add-022: group id length exceeds maximum limit defined in the schema"
	group_length_exceed_max=$(openssl rand -hex 10000 |  perl -p -e 's/\n//')
	command="pki -d $CERTDB_DIR -n $(eval echo \$${subsystemId}_adminV_user) -c $CERTDB_DIR_PASSWORD -h $TPS_HOST -p $TPS_PORT tps-group-add --description=test '$group_length_exceed_max'"
	errmsg="ClientResponseFailure: ldap can't save, exceeds max length"
	errorcode=255
	rlRun "verifyErrorMsg \"$command\" \"$errmsg\" \"$errorcode\"" 0 "Verify expected error message - Add Group -- group id exceeds max limit"
        rlLog "PKI Ticket::  https://fedorahosted.org/pki/ticket/842"
    rlPhaseEnd

    rlPhaseStartTest "pki_tps_group_cli_tps_group_add-023: description with i18n characters"
	rlLog "tps-group-add description ??rjan ??ke with i18n characters"
        rlLog "pki -d $CERTDB_DIR \
		   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TPS_HOST \
                    -p $TPS_PORT \ 
                    tps-group-add --description='??rjan ??ke' g4"
        rlRun "pki -d $CERTDB_DIR \
		   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TPS_HOST \
                    -p $TPS_PORT \
                    tps-group-add --description='??rjan ??ke' g4 > $TmpDir/pki-tps-group-add-001_51.out 2>&1" \
                    0 \
                    "Adding g4 with description ??rjan ??ke"
	rlAssertGrep "Added group \"g4\"" "$TmpDir/pki-tps-group-add-001_51.out"
        rlAssertGrep "Group ID: g4" "$TmpDir/pki-tps-group-add-001_51.out"
        rlAssertGrep "Description: ??rjan ??ke" "$TmpDir/pki-tps-group-add-001_51.out"
    rlPhaseEnd

    rlPhaseStartTest "pki_tps_group_cli_tps_group_add-024: description with i18n characters"
	rlLog "tps-group-add description ??ric T??ko with i18n characters"
        rlLog "pki -d $CERTDB_DIR \
		   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TPS_HOST \
                    -p $TPS_PORT \
                    tps-group-add --description='??ric T??ko' g5"
        rlRun "pki -d $CERTDB_DIR \
		   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TPS_HOST \
                    -p $TPS_PORT \
                    tps-group-add --description='??ric T??ko' g5 > $TmpDir/pki-tps-group-add-001_52.out 2>&1" \
                    0 \
                    "Adding g5 with description ??ric T??ko"
        rlAssertGrep "Added group \"g5\"" "$TmpDir/pki-tps-group-add-001_52.out"
        rlAssertGrep "Group ID: g5" "$TmpDir/pki-tps-group-add-001_52.out"
        rlAssertGrep "Description: ??ric T??ko" "$TmpDir/pki-tps-group-add-001_52.out"
    rlPhaseEnd 

    rlPhaseStartTest "pki_tps_group_cli_tps_group_add-025: description with i18n characters"
	rlLog "tps-group-add description ????nentwintig dvide??imt with i18n characters"
        rlLog "pki -d $CERTDB_DIR \
		   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TPS_HOST \
                    -p $TPS_PORT \
                    tps-group-add --description='????nentwintig dvide??imt' g6"
        rlRun "pki -d $CERTDB_DIR \
		   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TPS_HOST \
                    -p $TPS_PORT \
                    tps-group-add --description='????nentwintig dvide??imt' g6 > $TmpDir/pki-tps-group-add-001_53.out 2>&1" \
                    0 \
                    "Adding description ????nentwintig dvide??imt with i18n characters"
        rlAssertGrep "Added group \"g6\"" "$TmpDir/pki-tps-group-add-001_53.out"
        rlAssertGrep "Description: ????nentwintig dvide??imt" "$TmpDir/pki-tps-group-add-001_53.out"
        rlAssertGrep "Group ID: g6" "$TmpDir/pki-tps-group-add-001_53.out"
	rlLog "pki -d $CERTDB_DIR \
		   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TPS_HOST \
                    -p $TPS_PORT \
                    tps-group-show g6"
        rlRun "pki -d $CERTDB_DIR \
		   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TPS_HOST \
                    -p $TPS_PORT \
                    tps-group-show g6 > $TmpDir/pki-tps-group-add-001_53_2.out 2>&1" \
                    0 \
                    "Show group g6 with description ????nentwintig dvide??imt in i18n characters"
        rlAssertGrep "Group \"g6\"" "$TmpDir/pki-tps-group-add-001_53_2.out"
        rlAssertGrep "Description: ????nentwintig dvide??imt" "$TmpDir/pki-tps-group-add-001_53_2.out"
    rlPhaseEnd


    rlPhaseStartTest "pki_tps_group_cli_tps_group_add-026: group id with i18n characters"
        rlLog "pki -d $CERTDB_DIR \
		   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TPS_HOST \
                    -p $TPS_PORT \
                    tps-group-add --description=test '??rjan??ke'"
        rlRun "pki -d $CERTDB_DIR \
		   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TPS_HOST \
                    -p $TPS_PORT \
                    tps-group-add --description=test '??rjan??ke' > $TmpDir/pki-tps-group-add-001_56.out 2>&1" \
                    0 \
                    "Adding gid ??rjan??ke with i18n characters"
        rlAssertGrep "Added group \"??rjan??ke\"" "$TmpDir/pki-tps-group-add-001_56.out"
        rlAssertGrep "Group ID: ??rjan??ke" "$TmpDir/pki-tps-group-add-001_56.out"
    rlPhaseEnd

    rlPhaseStartTest "pki_tps_group_cli_tps_group_add-027: groupid with i18n characters"
        rlLog "pki -d $CERTDB_DIR \
		   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TPS_HOST \
                    -p $TPS_PORT \
                    tps-group-add --description=test '??ricT??ko'"
        rlRun "pki -d $CERTDB_DIR \
		   -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TPS_HOST \
                    -p $TPS_PORT \
                    tps-group-add --description=test '??ricT??ko' > $TmpDir/pki-tps-group-add-001_57.out 2>&1" \
                    0 \
                    "Adding group id ??ricT??ko with i18n characters"
        rlAssertGrep "Added group \"??ricT??ko\"" "$TmpDir/pki-tps-group-add-001_57.out"
        rlAssertGrep "Group ID: ??ricT??ko" "$TmpDir/pki-tps-group-add-001_57.out"
    rlPhaseEnd


    rlPhaseStartTest "pki_tps_group_cli_tps_group_cleanup: Deleting groups"

        #===Deleting groups created using TPS_adminV cert===#
        i=1
        while [ $i -lt 8 ] ; do
               rlRun "pki -d $CERTDB_DIR \
			  -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TPS_HOST \
                    -p $TPS_PORT \
                           tps-group-del  g$i > $TmpDir/pki-tps-group-del-group-00$i.out" \
                           0 \
                           "Deleted group  g$i"
                rlAssertGrep "Deleted group \"g$i\"" "$TmpDir/pki-tps-group-del-group-00$i.out"
                let i=$i+1
        done
        #===Deleting groups(symbols) created using TPS_adminV cert===#
        j=1
        while [ $j -lt 8 ] ; do
               eval grp=\$group$j
               rlRun "pki -d $CERTDB_DIR \
			  -n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TPS_HOST \
                    -p $TPS_PORT \
                           tps-group-del  '$grp' > $TmpDir/pki-tps-group-del-group-symbol-00$j.out" \
                           0 \
                           "Deleted group $grp"
		actual_delete_group_string=`cat $TmpDir/pki-tps-group-del-group-symbol-00$j.out | grep 'Deleted group' | xargs echo`
        	expected_delete_group_string="Deleted group $grp"
		if [[ $actual_delete_group_string = $expected_delete_group_string ]] ; then
                	rlPass "Deleted group \"$grp\" found in $TmpDir/pki-tps-group-del-group-symbol-00$j.out"
        	else
                	rlFail "Deleted group \"$grp\" not found in $TmpDir/pki-tps-group-del-group-symbol-00$j.out" 
        	fi
                let j=$j+1
        done
        #===Deleting i18n groups created using TPS_adminV cert===#
	rlRun "pki -d $CERTDB_DIR \
		-n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TPS_HOST \
                    -p $TPS_PORT \
	tps-group-del '??rjan??ke' > $TmpDir/pki-tps-group-del-group-i18n_1.out" \
		0 \
		"Deleted group ??rjan??ke"
	rlAssertGrep "Deleted group \"??rjan??ke\"" "$TmpDir/pki-tps-group-del-group-i18n_1.out"
	
	rlRun "pki -d $CERTDB_DIR \
		-n $(eval echo \$${subsystemId}_adminV_user) \
                    -c $CERTDB_DIR_PASSWORD \
                    -h $TPS_HOST \
                    -p $TPS_PORT \
                tps-group-del '??ricT??ko' > $TmpDir/pki-tps-group-del-group-i18n_2.out" \
                0 \
                "Deleted group ??ricT??ko"
        rlAssertGrep "Deleted group \"??ricT??ko\"" "$TmpDir/pki-tps-group-del-group-i18n_2.out"

	#Delete temporary directory
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
    rlPhaseEnd
else
        rlPhaseStartCleanup "pki tps-group-add cleanup: Delete temp dir"
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
        rlLog "TPS subsystem is not installed"
        rlPhaseEnd
fi
}
