# websocketの読み込み
require 'em-websocket'
# 中身を見やすく表示するため、デバック用
require 'pp'
# ランダムの文字列を生成するため
require 'securerandom'

# クライアントのデータを入れる箱
connections = []
# ユーザを入れる箱（二次元配列）
user_list = []

# Webscocketの通信開始
EM::WebSocket.start({:host => "0.0.0.0", :port => 8888}) do |ws_conn|
  # クライアントから接続が合った時
  ws_conn.onopen do
    # クライアントのデータを入れる
    connections  << ws_conn
    # 接続数を表示
    printf("%d GUEST Login\n", connections.length)
    # 接続数を全クライアントに送信
    connections.each{|conn| conn.send("user_num,#{connections.length}")}
    # ユーザリストを接続が合った人だけに送信
    connections.each{|conn|
      if (conn == ws_conn)
        # もし、一番最初のユーザだったら送らない
        if (user_list.length != 0)
          user_list.each{|list|
            conn.send("user_list,#{list[0]},#{list[1]}")
          }
        end
      end
    }
  end

  # クライアントからのメッセージがきたとき
  ws_conn.onmessage do |message|
    # メッセージをカンマで区切る
    user_info = message.split(",")
    # もし、名前のめっせーじがきたら
    if (user_info[0] == "user_name")
      # id用のランダムな文字列を生成
      user_id = SecureRandom.alphanumeric
      # 名前とidをユーザリストに追加
      user_list << [user_info[1],user_id]
      # そのユーザリストを送ってきたやつとそれ以外に送信
      # 他の人にはnew_userという文字列を一緒に返し
      # 送ってきたやつにはmy_selfという文字列を一緒に返す
      connections.each{|conn|
        if (conn != ws_conn)
          conn.send("new_user,#{user_list[-1][0]},#{user_list[-1][1]}")
        else
          conn.send("my_self,#{user_list[-1][0]},#{user_list[-1][1]}")
        end
      }

      # もし、メッセージが来たら全員に送信
    elsif (user_info[0] == "message")
      connections.each{|conn| conn.send(message)}
    end
  end

  # もし、クライアントの接続が切れたら
  ws_conn.onclose do
    # 切れたクライアント情報が配列の何番目か探す
    i = connections.index(ws_conn);
    # ユーザーリストの番号と同じなのでそれの情報を送信し、そいつの情報を削除させる(js)
    connections.each{|conn|
      conn.send("logout,#{user_list[i][0]},#{user_list[i][1]}")
    }
    # ログアウトのユーザーを表示
    printf("%s is logout\n",user_list[i][0])
    # ユーザーリストとクライアント情報を削除
    user_list.delete_at(i)
    connections.delete(ws_conn)
    # 接続数を送信
    connections.each{|conn| conn.send "user_num,#{connections.length}"}
  end

end
