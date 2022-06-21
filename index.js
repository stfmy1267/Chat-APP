const ws = new WebSocket('ws://localhost:8888/');

const sendBtn = document.getElementById('bms_send_btn');
const bmsSendMessage = document.getElementById('bms_send_message');
const msgArea = document.getElementById('msg-area');
const user = document.getElementById('user');
const info = document.getElementById('info');

let user_list = []

// user.innerHTML= "fumiya"
const disp = () => {
    // 入力ダイアログを表示 ＋ 入力内容を user に代入
    while (true) {
        let users = window.prompt("ユーザー名を入力してください\n匿名希望はキャンセルをクリック", "");
        if (users == null) {
            window.alert('キャンセルされました');
            users = "名無しさん";
            return users;
        }
        else if (users === "") {
            window.alert('ユーザ名を登録してください')
        }
        else {
            return users;
        }
    }
}

let user_name = disp();
ws.onopen = () => {
    let user_info = ["user_name", user_name];
    ws.send(user_info);
}
// ようこそ文
user.innerHTML = "Hi, " + user_name + " welcome to the Chat App"

// メッセージ送信
sendBtn.addEventListener('click', (e) => {
    msg = bmsSendMessage.value
    const arry = ["message", user_name, msg]
    ws.send(arry);
    bmsSendMessage.value = "";
})

// エラー時の処理
ws.onerror = function (err) {
    alert('WebSocket failure: ' + err)
};

// メッセージを受け取った時
ws.onmessage = (e) => {
    let hash = [];
    hash = e.data.split(",");
    if (hash[0] == "user_num") {
        info.textContent = hash[1] + "人がログイン中";
    }

    else if (hash[0] == "user_list") {
        console.log(hash);
        user_list.push([hash[1],hash[2]]);
        // if (hash[2] != user_id) {
        // }
    }


    else if (hash[0] == "my_self"){
        console.log(e.data);
        console.log(hash[2]);

        user_list.push([hash[1],hash[2]]);
        console.log(user_list);
    }

    else if (hash[0] == "new_user") {
        console.log(e.data);
        console.log(hash);

        user_list.push([hash[1],hash[2]]);
        console.log(user_list);
        window.alert(hash[1] + "がログインしました");
    }

    else if (hash[0] == "message") {
        //  ["message", "hogehoge", "こんにちわ"]
        let msgli = document.createElement("li")
        msgli.textContent = hash[1] + " : " + hash[2];
        msgArea.appendChild(msgli);
    }

    else if(hash[0] == "logout"){
        user_list.pop(hash[1],hash[2]);
        window.alert(hash[1] + "ログアウトしました");
        console.log(user_list);
    }

};

// サーバーが終了した時
ws.onclose = () => {
    info.textContent = "終了しました";
    ws = null;
};
