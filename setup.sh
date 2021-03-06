#!/bin/bash

# yes 혹은 no 선택하는 함수 (받는 값을 그대로 사용해도 무방하나, 여러 가능성을 고려해 작성함)
__check__() {
    case $1 in
    Yes|YES|yes|y|Y)
        echo 1
        ;;
    No|NO|no|N|n)
        echo 2
        ;;
    *)
        echo 3
    esac
}

# apm 설치
__apm__() {
    clear

    sudo apt update & sudo apt upgrade 

    # apache2, php, mysql 설치
    sudo apt install apache2 php php-mysql mysql-server -y

    # apache2 실행
    sudo service apache2 start
}

# github 연동
__github__() {
    clear

    # ascii text 불러오기
    cat ascii/github.txt

    # /var/www/html의 파일들을 날릴 수 있다는 경고 문구 삽입 및 확인
    read -p "[warning] /var/www/html 경로를 덮어씌우게 됩니다! 계속 진행하겠습니까? (yes, no): " cover
    
    # 사용자의 선택
    cover_ans=$(__check__ $cover)

    if [ $cover_ans -eq 1 ]
    then
        # html 폴더 삭제
        sudo rm -rf /var/www/html

        # .git 주소 받아오기
        read -p ".git address: " git_addr

        # /var/www/html로 git clone
        sudo git clone $git_addr /var/www/html

        # pull.sh 생성 및 권한 부여
        cd /var/www/html
        sudo echo -e '#!/bin/sh\ngit pull' > /var/www/html/pull.sh
        sudo chmod +x pull.sh

        # github 계정 저장 여부
        read -p "github 계정을 저장하겠습니까? (yes, no): " store

        # 사용자의 선택
        store_ans=$(__check__ $store)

        if [ $store_ans -eq 1 ]
        then
            # github credential 정보 저장
            sudo git config credential.helper store
        
        fi
        
    elif [ $cover_ans -eq 2 ]
    then
        # 취소 메시지 출력
        echo "cancel"
    
    else
        # 잘못된 입력 출력
        echo "Invalid"
    
    fi
}

# apache2 포트 변경
__apache2__() {
    clear

    # ascii text 불러오기
    cat ascii/apache2.txt

    # 현재 포트 가져오기
    read -p "현재 포트번호를 입력하세요 (변경한 적 없다면 80을 입력해주세요): " now_port

    # 바꿀 포트 가져오기
    read -p "변경하고자 하는 포트번호를 입력하세요(사용 가능한 포트여야합니다!): " chg_port

    # /etc/apache2/ports.conf 변경
    sudo sed -i "s/Listen ${now_port}/Listen ${chg_port}/g" /etc/apache2/ports.conf

    # /etc/apache2/sites-available/000-default.conf 변경
    sudo sed -i "s/*:${now_port}/*:${chg_port}/g" /etc/apache2/sites-available/000-default.conf

    # apache2 재실행
    sudo service apache2 restart
    
    echo "Done!!"
}

# crontab + git pull 자동화
__pull__() {
    clear

    # ascii text 불러오기
    cat ascii/crontab.txt

    # crontab 시간 선택
    read -p "몇 분마다 받을지 선택해주세요 (1~60): " cron_time

    # 이미 cron이 있다면 삭제 
    sudo sed -i '/pull.sh/d' /etc/crontab

    # 새 crontab 작성
    sudo echo "*/${cron_time} * * * * root cd /var/www/html && /var/www/html/pull.sh" >> /etc/crontab

    # crontab 재실행
    sudo service cron restart
}

# main
clear

# ascii text 불러오기
cat ascii/kknock.txt

echo -e "\n1) apm 설치 및 apache2 실행
2) github /var/www/html에 연동
3) apache2 포트 변경
4) git pull 시간 변경\n"

read -p "번호를 입력해주세요: " select_num

case $select_num in
    1)
    __apm__
    ;;
    
    2)
    __github__
    ;;

    3)
    __apache2__
    ;;

    4)
    __pull__
    ;;
esac


