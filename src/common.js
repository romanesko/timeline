class Cookie {

  static get(name) {
    var nameEQ = name + "=";
    var cookies = document.cookie.split(';');
    for (var i = 0; i < cookies.length; i++) {
      var cookie = cookies[i];
      while (cookie.charAt(0) === ' ') {
        cookie = cookie.substring(1, cookie.length);
      }
      if (cookie.indexOf(nameEQ) === 0) {
        return cookie.substring(nameEQ.length, cookie.length);
      }
    }
    return null;
  }


  static set(name, value, days) {
    var expires = "";
    if (days) {
      var date = new Date();
      date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
      expires = "; expires=" + date.toUTCString();
    }
    document.cookie = name + "=" + value + expires + "; path=/";
  }

  static delete(name) {
    document.cookie = name + "=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
  }

}


class Api {

  constructor() {
    this.token = Cookie.get('token')

  }

  isLoggedIn() {
    return Boolean(this.token)
  }

  #headers() {
    const token = Cookie.get('token');
    if (!token) {
      return {}
    }
    return { 'Authorization': 'Token ' + token }
  }

  async login(login,password){
    return api.post('login',{login, password}).then(a=>{
      if(!a) {return}
      this.token = a.token
      Cookie.set('token', this.token,30)
    })        
  }

  async logout(){
    console.log(this)
    this.token = undefined
    Cookie.delete('token')
    document.location.reload()
  }

  get(method, params) {

    let urlAdd = ''
    if (params) {
      urlAdd = '?' + new URLSearchParams(params)
    }

    return fetch('https://api.x125.ru/rnd/' + method + urlAdd, {
      method: 'GET',
      headers: this.#headers()
    }).then(async (response) => {
      const data = await response.json()
      if (response.status == 401) {
        this.logout()
        return;
      }


      if (response.status != 200) {
        throw new Error(data.message)
      }
      return data
    })
  }

  post(method, params) {
    return fetch('https://api.x125.ru/rnd/' + method, {
      method: 'POST',
      body: JSON.stringify(params),
      headers: this.#headers()
    }).then(async (response) => {
      const data = await response.json()

      if (response.status == 401) {
        this.logout()
        return;
      }

      if (response.status != 200) {
        throw new Error(data.message)
      }
      return data
    })
  }

}

export const api = new Api()


