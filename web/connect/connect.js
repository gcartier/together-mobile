function show(obj) {
  console.log(obj)
}


/*
button = document.getElementById("notify")
button.addEventListener("click", () => {
  Notification.requestPermission().then(perm => {
    if (perm === "granted") {
      const notif = new Notification("Example", {
        body: "This is more text",
        // icon: "images/green_sphere.ico",
        silent: false,
        // tag: "Hello",
        data: { foo: "bar" }
      })

      notif.addEventListener("close", e => {
        show(e)
      })
    }
  })
})
*/


var flashClear = null

function titleFlasher(pageTitle, newTitle) {
  return function() {
    if (document.title == pageTitle) {
      document.title = newTitle;
    } else {
      document.title = pageTitle;
    }
  }
}

function flashTitle(pageTitle, newTitle) {
  if (document.visibilityState === 'hidden' && !flashClear) {
    let interval = setInterval(titleFlasher(pageTitle, newTitle), 1500)
    flashClear = function() {
      clearInterval(interval)
      document.title = pageTitle
    }
  }
}

document.addEventListener('visibilitychange', function(ev) {
  if (document.visibilityState === 'visible' && flashClear) {
    flashClear()
    flashClear = null
  }
})


function beep(soundSource, volume){
  return new Promise((resolve, reject) => {
    volume = volume || 100

    try {
      let sound = new Audio(soundSource)

      sound.volume = volume / 100

      sound.onended = () => {
        resolve()
      }

      sound.play()
    } catch(error) {
      reject(error)
    }
  })
}
