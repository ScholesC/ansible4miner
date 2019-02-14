#!/bin/env python
# -*- coding: utf-8 -*-
import os
import sys
import json,time
import argparse
from collections import namedtuple
from ansible.parsing.dataloader import DataLoader
from ansible.vars import VariableManager
from ansible.inventory import Inventory
from ansible.playbook.play import Play
from ansible.executor.task_queue_manager import TaskQueueManager
from ansible.executor.playbook_executor import PlaybookExecutor
from ansible.plugins.callback import CallbackBase
from ansible.module_utils._text import to_bytes
from ansible import constants as C
from ansible.utils.color import colorize, hostcolor

class ResultCallback(CallbackBase):
    def __init__(self, *args, **kwargs):
        super(ResultCallback, self).__init__(*args, **kwargs)
        self.host_ok = {}
        self.host_unreachable = {}
        self.host_failed = {}
        self.list_=[]
    def v2_runner_on_unreachable(self, result):
        print result._host, result._task.get_name()
        print result._result
        self.list_=[]
        if result._host.get_name() in self.host_unreachable.keys():
            self.list_=self.host_unreachable[result._host.get_name()]
            self.list_.append({result._task.get_name():result._result['changed']})
        else:
            self.list_.append({result._task.get_name():result._result['changed']})
        key=str(result._host.get_name())
        self.host_unreachable[key] = self.list_
        #self.host_unreachable[result._host.get_name()] = result
    def v2_runner_on_ok(self, result,  *args, **kwargs):
        print result._host, result._task.get_name()
        #print result._task.get_name()
        #print result._result
        self.list_=[]
        if result._host.get_name() in self.host_ok.keys():
            self.list_=self.host_ok[result._host.get_name()]
            self.list_.append({result._task.get_name():result._result['changed']})
            try:
                for result_fact in result._result['results']:
                    self.list_.append({'ansible_facts':result_fact['ansible_facts']})
            except:
                pass
            try:
                self.list_.append({'command_name':result._result['cmd']})
                self.list_.append({'command_result':result._result['stdout']})
            except:
                pass
        else:
            self.list_.append({result._task.get_name():result._result['changed']})
            try:
                for result_fact in result._result['results']:
                    self.list_.append({'ansible_facts':result_fact['ansible_facts']})
            except:
                pass
            try:
                self.list_.append({'command_name':result._result['cmd']})
                self.list_.append({'command_result':result._result['stdout']})
            except:
                pass
        key=str(result._host.get_name())
        self.host_ok[key] = self.list_
        #self.host_ok[result._task.get_name()] = result._result['changed']
        #self.host_ok[result._host.get_name()] = result._task
    def v2_runner_on_failed(self, result,  *args, **kwargs):
        print result._host, result._task.get_name()
        print result._result
        self.list_=[]
        if result._host.get_name() in self.host_failed.keys():
            self.list_=self.host_failed[result._host.get_name()]
            self.list_.append({result._task.get_name():result._result['changed']})
        else:
            self.list_.append({result._task.get_name():result._result['changed']})
        key=str(result._host.get_name())
        self.host_failed[key] = self.list_
        #self.host_failed[result._host.get_name()] = result

def run_playbook(host_list,playbook_path,extra_data):
    extra_vars= extra_data
    variable_manager = VariableManager()
    variable_manager.extra_vars=extra_vars
    loader = DataLoader()
    results_callback = ResultCallback()
    inventory = Inventory(loader=loader, variable_manager=variable_manager, host_list=host_list)
    playbook_path = playbook_path
    Options = namedtuple('Options', [
        'listtags', 'listtasks', 'listhosts', 'syntax', 'connection','module_path', 
        'forks', 'remote_user', 'private_key_file','ssh_common_args','ssh_extra_args',
        'sftp_extra_args', 'scp_extra_args', 'become', 'become_method', 'become_user', 'verbosity', 'check'
    ])
    options = Options(listtags=False, listtasks=False, listhosts=False, syntax=False, connection='ssh', 
        module_path=None, forks=100, remote_user='eth', private_key_file=None, ssh_common_args=None, 
        ssh_extra_args=None, sftp_extra_args=None, scp_extra_args=None, become=True, become_method='sudo', become_user='root', verbosity=None, check=False        
    )
    passwords = {}
    pbex = PlaybookExecutor(playbooks=[playbook_path], inventory=inventory, variable_manager=variable_manager, loader=loader, options=options, passwords=passwords)
    callback = ResultCallback()
    pbex._tqm._stdout_callback = callback
    pbex.run()
    results_raw = {'success':{}, 'failed':{}, 'unreachable':{}}
    for host, result in callback.host_ok.items():
        results_raw['success'][host] = result
    for host, result in callback.host_failed.items():
        results_raw['failed'][host] = result
    for host, result in callback.host_unreachable.items():
        results_raw['unreachable'][host]= result
        #results_raw['unreachable'][host]= result._result['msg']
    return results_raw

def run_command(host_list,command):
    variable_manager = VariableManager()
    loader = DataLoader()
    inventory = Inventory(loader=loader, variable_manager=variable_manager, host_list=host_list)
    Options = namedtuple('Options', ['connection', 'module_path', 'forks', 'become', 'become_method', 'become_user', 'check'])
    options = Options(connection='ssh', module_path=None, forks=100, become=None, become_method=None, become_user=None, check=False)
    passwords = {}
    play_source =  dict(
            name = "Ansible Play",
            hosts = 'all',
            gather_facts = 'no',
            tasks = [
                    dict(action=dict(module='shell', args=command), register='shell_out'),
        #    dict(action=dict(module='debug', args=dict(msg='{{shell_out.stdout}}')))
            ]
        )
    play = Play().load(play_source, variable_manager=variable_manager, loader=loader)
    pbex = TaskQueueManager(inventory=inventory, variable_manager=variable_manager, loader=loader, options=options, passwords=passwords)
    callback = ResultCallback()
    pbex._stdout_callback = callback
    pbex.run(play)
    results_raw = {'success':{}, 'failed':{}, 'unreachable':{}}
    for host, result in callback.host_ok.items():
        results_raw['success'][host] = result
    for host, result in callback.host_failed.items():
        results_raw['failed'][host] = result
    for host, result in callback.host_unreachable.items():
        results_raw['unreachable'][host]= result
        #results_raw['unreachable'][host]= result._result['msg']
    return results_raw
    
def main():
    parser = argparse.ArgumentParser(description="矿机初始化脚本")
    parser.add_argument("-s", "--servers", help="机器",
                        action="store", dest='servers',
                        required=True, nargs='+',
                        type=str)
    parser.add_argument("-p", "--password", help="密码",
                        action="store", dest='passwd',
                        required=True,
                        type=str)
    parser.add_argument("-t", "--type", help="btm 或者 rvn",
                        action="store", dest='m_type', choices=['btm', 'rvn', 'ae', 'grin', 'beam', 'grin31'],
                        required=False,
                        type=str)
    parser.add_argument("-a", "--addr", help="钱包地址",
                        action="store", dest='m_addr',
                        required=False,
                        type=str)
    parser.add_argument("-d", "--dtype", help="初始化 或者 推送挖矿软件",
                        action="store", dest='m_dtype', choices=['os_init', 'miner', 'all'],
                        default="os_init",
                        required=False,
                        type=str)
    args = parser.parse_args()
    servers = args.servers
    password = args.passwd
    m_type = args.m_type
    m_addr = args.m_addr
    m_dtype = args.m_dtype
    print servers
    playbook_path='/home/eth/ansible/os_init.yml'
    extra_data={}
    extra_data['ansible_sudo_pass']=password
    extra_data['ansible_ssh_pass']=password
    if m_dtype == "os_init" or m_dtype == "all":
        run_playbook(servers,playbook_path,extra_data)
    if m_addr and m_type:
        server_list = " ".join(servers)
        os.system('pssh -i -H "{0}" "rm -rvf /home/eth/{1}"'.format(server_list, m_type))
        os.system('echo {0} > miners/{1}/{1}/address.txt'.format(m_addr, m_type))
        os.system('prsync -av -H "{0}" miners/{1}/ /home/eth/'.format(server_list, m_type))
        os.system('pssh -i -H "{0}" "sudo reboot"'.format(server_list, m_type))


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print "\nExiting......\n"
        sys.exit(0)
    
