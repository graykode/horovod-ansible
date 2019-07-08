## horovod-ansible

<p align="center"><img width="180" src="https://user-images.githubusercontent.com/16640218/34506318-84d0c06c-efe0-11e7-8831-0425772ed8f2.png" />  <img width="120" src="https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Ansible_logo.svg/512px-Ansible_logo.svg.png" /></p>
[Horovod](https://github.com/horovod/horovod) is a distributed training framework for TensorFlow, Keras, PyTorch, and MXNet. [Ansible](https://github.com/ansible/ansible) is a radically simple IT automation system. We can easily install the horovod on all server through its automatic setup on **AWS or On-premise**

##### Before Start

- All On-premise nodes should be ubuntu>=16.04. **I assumed that all nodes were equipped with Ansible(On-premise)**
- Until now, only the examples of tensorflow and pyrotorch can used(Not MXNet, Caffe.. etc YET).
- `AWS` Step : 0 - 1 -3
- `On-perm` Step : 0 - 2 - 3



## Usage

### 0. docker setting(both AWS, On-premise)
All steps will be conducted under Docker container for beginners.

```bash
$ docker run -it --name horovod-ansible graykode/horovod-ansible:0.1 /bin/bash
```



### 1. AWS

To create horovod clustering enviorment, start provisioning with `Terraform` code. Change some option [`variables.tf`](https://github.com/graykode/horovod-ansible/blob/master/terraform/variables.tf) which you want. But you should not below `## DO NOT CHANGE BELOW`.

If I created EC2 with option `number_of_worker` 3, Total architecture is same with below picture.

<p align="center"><img width="600" src="https://raw.githubusercontent.com/graykode/horovod-ansible/master/images/horovod.png" /> </p>
Export your own AWS Access / Secret keys

```bash
$ export AWS_ACCESS_KEY_ID=<Your Access Key in AWS>
$ export AWS_SECRET_ACCESS_KEY=<Your Access Key in Secret>
```

Initializing terraform and create private key to use.

```bash
$ cd terraform/ && ssh-keygen -t rsa -N "" -f horovod
$ terraform init
```

provisioning all resource EC2, VPC(gateway, router, subnet, etc..) 

```bash
$ terraform apply
```

Then, you can get output :

```bash
Apply complete! Resources: 12 added, 0 changed, 0 destroyed.

Outputs:

horovod_master_public_ip = <master's public IP>
horovod_workers_public_ip = <worker0's public IP>,<worker1's public IP>
```



### 2. On-premise

As I said above, assume that all nodes are 'ansible' and network setup is finished. If you want to see install Ansible, Please read [Ansible Install Guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) on document.



### 3. Setup Horovod Configure using Ansible(both AWS, On-premise)

Install `ansible` and `jinja2` using pip.
```bash
$ ../ansible && pip install -r requirements.txt
```



Set `inventory.ini` in Ansible Folder.

```ini
master ansible_host=<master's public IP>
worker0 ansible_host=<worker0's public IP>
worker1 ansible_host=<worker1's public IP>
....
worker[n] ansible_host=

[all]
master
worker0
worker1
...
worker[n]

[master-servers]
master

[worker-servers]
worker0
worker1
...
worker[n]
```



Ping Test to all nodes!

```bash
$ chmod +x ping.sh && ./ping.sh
```

Now ssh configure to using Open MPI, Download Open MPI and build

```bash
$ chmod +x playbook.sh && ./playbook.sh
```

Test all nodes of mpi that it is fine in master node.

```bash
$ chmod +x test.sh && ./test.sh

# go to master node.
ubuntu@master:~$ mpirun -np 3 -mca btl sm,self,tcp -host master,worker0,worker1 ./test
Processor name: master
master (0/3)
Processor name: worker0
slave  (1/3)
Processor name: worker1
slave  (2/3)
```



### 4. Install DeepLearning Framework which you want and Horovod(both AWS, On-premise)

I'd like you to change this part fluidly.

- Install Tensorflow on CPU, Horovod and Run Distributed 

  ```bash
  $ chmod +x tensorflow.sh && ./tensorflow.sh
  
  # go to master node.
  ubuntu@master:~$ horovodrun -np 3 -H master,worker0,worker2 python3 tensorflow-train.py
  ```

- Install Pytorch on CPU, Horovod and Run Distributed 

  ```bash
  $ chmod +x pytorch.sh && ./pytorch.sh
  
  # go to master node.
  ubuntu@master:~$ horovodrun -np 3 -H master,worker0,worker2 python3 pytorch-train.py
  ```

- Issue Note : If you want to change framework after install horovod, you reinstall horovod with `HOROVOD_WITH_*` option, '*' is just framework name. please see [horovod issue](https://github.com/horovod/horovod/issues/314). But in my Ansible Script, I 'm not add it yet.



## Author

- Tae Hwan Jung(Jeff Jung) @graykode
- Author Email : [nlkey2022@gmail.com](mailto:nlkey2022@gmail.com)