# Introduction to GPU Cluster

## What is a GPU cluster?

A GPU cluster consists of many GPU servers. Your training/inference job gets
distributed automatically by a job scheduler. This allows us to serve more
users.

## What's in it for me?

Instead of waiting someone that is occupying your assigned GPU server to finish
their business, you can tell the cluster that you want to do something and wait
in a queue. As soon as one machine in the cluster starts idling, your
instruction starts running on this machine.

Your data is always synced on all GPU servers in the cluster. When you switch
between servers, your data stays the same.

## How do I interact with the cluster?

You need to be familiar with interacting Linux-based systems via terminals. See
this:
[What are shell, bash, and terminal?](https://linuxcommand.org/lc3_lts0010.php)

In other words, you type what you need via Terminals.This is different from
Windows where you click buttons to achieve what you want.

For our cluster, you need to SSH (i.e., remote connect) into our cluster and
instruct the servers to achieve what you want. Your laptop will essentially be a
remote control telling our servers what to do. Being a remote control takes much
less computer power, so your laptop doesn't need to be a cooking pan when
running your code. [What's SSH?](https://www.youtube.com/watch?v=v45p_kJV9i4)
