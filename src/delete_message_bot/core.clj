(ns delete-message-bot.core
  (:gen-class))

(def bot (com.pengrad.telegrambot.TelegramBot. (java.lang.System/getenv "TELEGRAM_TOKEN")))

(defn handle-update [updates]
  (doseq [x updates]
    (let [chat-id (.id (.chat (.message x)))]
      (if (some? (.newChatMembers (.message x)))
        (->>
         (.messageId (.message x))
         (com.pengrad.telegrambot.request.DeleteMessage. chat-id)
         (.execute bot))))))

(.setUpdatesListener
 bot
 (reify com.pengrad.telegrambot.UpdatesListener
   (process [_ updates]
     (try
       (handle-update updates)
       (catch Exception ex
         (.printStackTrace ex)))
     -1)))

(defn -main
  "I don't do a whole lot ... yet."
  [& args]
  (println "Hello, World!"))
