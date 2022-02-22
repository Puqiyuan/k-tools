while inotifywait -r -e modify,create,delete /home/pqy7172/gcc; do
    rsync -avz /home/pqy7172/gcc pqy@cs6.swfu.edu.cn:/var/home/pqy/
done
