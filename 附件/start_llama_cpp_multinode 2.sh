#!/bin/bash

# 基础端口号
BASE_PORT=50052

# 检查是否安装了tmux
if ! command -v tmux &> /dev/null; then
    echo "请先安装 tmux: sudo apt-get install tmux"
    exit 1
fi

# 创建新的tmux会话
tmux new-session -d -s llama_servers

# 循环创建8个服务器实例
for i in {0..7}
do
    # 计算当前端口号
    PORT=$((BASE_PORT + i))
    
    # 创建新窗口并执行命令
    tmux new-window -t llama_servers:$i -n "GPU$i" "
        echo '启动 GPU $i 上的服务器，端口号: $PORT';
        docker exec -it llamacpp_from_torch /bin/bash -c '
            cd /home/hanxianlin/workspace/llama.cpp/build-rpc-cuda && \
            CUDA_VISIBLE_DEVICES=$i bin/rpc-server -p $PORT
        '"
done

# 附加到tmux会话
tmux attach-session -t llama_servers