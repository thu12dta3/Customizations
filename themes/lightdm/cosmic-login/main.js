'use strict';

(() => {
  const $ = (id) => document.getElementById(id);
  const clock = $('clock');
  const date = $('date');
  const form = $('login-form');
  const accountName = $('account-name');
  const userPicker = $('user-picker');
  const userTrigger = $('user-trigger');
  const userMenu = $('user-menu');
  const userAvatar = $('user-avatar');
  const userInitials = $('user-initials');
  const password = $('password');
  const message = $('message');
  const loginButton = $('login-button');
  const restartButton = $('restart-button');
  const shutdownButton = $('shutdown-button');
  let pendingSecret = '';
  let authenticating = false;
  let awaitingPrompt = false;
  let activeUsername = '';
  const lockedSession = 'plasma';

  function updateTime() {
    const now = new Date();
    clock.textContent = new Intl.DateTimeFormat('pt-BR', { hour: '2-digit', minute: '2-digit', hourCycle: 'h23' }).format(now);
    const localizedDate = new Intl.DateTimeFormat('pt-BR', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' }).format(now);
    date.textContent = localizedDate.charAt(0).toLocaleUpperCase('pt-BR') + localizedDate.slice(1);
  }
  updateTime();
  window.setInterval(updateTime, 15000);

  function setMessage(text, kind = 'info') {
    message.textContent = text || '';
    message.dataset.kind = kind;
  }
  function setBusy(busy) {
    authenticating = busy;
    loginButton.disabled = busy;
    password.disabled = busy;
  }
  function initialsFor(user) {
    const label = user.display_name || user.real_name || user.username || user.name || '?';
    return label.trim().split(/\s+/).slice(0, 2).map((part) => part.charAt(0)).join('').toLocaleUpperCase('pt-BR') || '?';
  }
  function showUser(user) {
    activeUsername = user.username || user.name || '';
    accountName.textContent = user.display_name || user.real_name || activeUsername;
    userInitials.textContent = initialsFor(user);
    userAvatar.hidden = true;
    userAvatar.onerror = () => { userAvatar.hidden = true; };
    userAvatar.onload = () => { userAvatar.hidden = false; };
    userAvatar.removeAttribute('src');
    if (user.image) userAvatar.src = user.image;
  }
  function renderUserOptions(users, selectedUser) {
    userMenu.replaceChildren();
    users.forEach((user, index) => {
      const button = document.createElement('button');
      button.className = 'user-option';
      button.type = 'button';
      button.setAttribute('role', 'option');
      button.setAttribute('aria-selected', String(user === selectedUser));
      const avatar = document.createElement('span');
      avatar.className = 'avatar';
      const initials = document.createElement('span');
      initials.className = 'initials';
      initials.setAttribute('aria-hidden', 'true');
      initials.textContent = initialsFor(user);
      const image = document.createElement('img');
      image.alt = '';
      image.hidden = true;
      image.onerror = () => { image.hidden = true; };
      image.onload = () => { image.hidden = false; };
      if (user.image) image.src = user.image;
      avatar.append(image, initials);
      const label = document.createElement('span');
      label.textContent = user.display_name || user.real_name || user.username || user.name || `Usuário ${index + 1}`;
      button.append(avatar, label);
      button.addEventListener('click', () => {
        showUser(user);
        userMenu.querySelectorAll('[role="option"]').forEach((option) => option.setAttribute('aria-selected', 'false'));
        button.setAttribute('aria-selected', 'true');
        userMenu.hidden = true;
        userTrigger.setAttribute('aria-expanded', 'false');
        password.focus();
      });
      userMenu.append(button);
    });
  }
  function renderLightDM() {
    if (typeof window.lightdm === 'undefined') return false;
    const users = Array.from(lightdm.users || []).filter((user) => user.username || user.name);
    const hintedName = lightdm.select_user_hint;
    const selectedUser = users.find((user) => (user.username || user.name) === hintedName) || users[0];
    userPicker.dataset.single = String(users.length < 2);
    if (selectedUser) {
      showUser(selectedUser);
      renderUserOptions(users, selectedUser);
    } else if (hintedName) {
      activeUsername = hintedName;
      accountName.textContent = hintedName;
      userInitials.textContent = initialsFor({ username: hintedName });
    }
    userTrigger.disabled = users.length < 2;
    if (users.length > 1) userTrigger.setAttribute('aria-haspopup', 'listbox');
    else userTrigger.removeAttribute('aria-haspopup');
    restartButton.hidden = !lightdm.can_restart;
    shutdownButton.hidden = !lightdm.can_shutdown;
    return Boolean(activeUsername);
  }
  userTrigger.addEventListener('click', () => {
    if (userTrigger.disabled) return;
    userMenu.hidden = !userMenu.hidden;
    userTrigger.setAttribute('aria-expanded', String(!userMenu.hidden));
  });
  document.addEventListener('click', (event) => {
    if (!userPicker.contains(event.target)) {
      userMenu.hidden = true;
      userTrigger.setAttribute('aria-expanded', 'false');
    }
  });
  userPicker.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') {
      userMenu.hidden = true;
      userTrigger.setAttribute('aria-expanded', 'false');
      userTrigger.focus();
    }
  });
  function installAuthCallbacks() {
    // WebKit2 Greeter invokes these named page callbacks when LightDM emits events.
    window.show_prompt = (text, type) => {
      const promptType = String(type).toLowerCase();
      if (promptType === 'password' && pendingSecret !== '') {
        const response = pendingSecret;
        pendingSecret = '';
        lightdm.respond(response);
        return;
      }
      awaitingPrompt = true;
      setBusy(false);
      loginButton.setAttribute('aria-label', 'Responder');
      loginButton.title = 'Responder';
      setMessage(text || 'O LightDM solicitou uma resposta.');
      password.type = promptType === 'password' ? 'password' : 'text';
      password.setAttribute('autocomplete', promptType === 'password' ? 'current-password' : 'off');
      password.focus();
    };
    window.show_message = (text, type) => {
      const kind = String(type).toLowerCase().includes('error') ? 'error' : 'info';
      setMessage(text, kind);
    };
    window.authentication_complete = () => {
      awaitingPrompt = false;
      if (lightdm.is_authenticated) {
        setMessage('Acesso autorizado. Abrindo sessão…');
        if (!lightdm.start_session(lockedSession)) {
          setBusy(false);
          setMessage('Não foi possível iniciar a sessão selecionada.', 'error');
          password.focus();
        }
      } else {
        pendingSecret = '';
        password.value = '';
        password.type = 'password';
        setBusy(false);
        setMessage('Senha incorreta. Tente novamente.', 'error');
        password.focus();
      }
    };
  }

  const hasLightDM = renderLightDM();
  if (hasLightDM) {
    installAuthCallbacks();
    password.focus();
  } else {
    accountName.textContent = 'Usuário';
    $('preview-label').hidden = false;
    setMessage('Esta é apenas uma prévia visual. O login funciona no LightDM WebKit Greeter.', 'info');
    form.querySelectorAll('input, select, button').forEach((element) => { element.disabled = true; });
    restartButton.disabled = true;
    shutdownButton.disabled = true;
  }

  form.addEventListener('submit', (event) => {
    event.preventDefault();
    if (!hasLightDM) return;
    if (awaitingPrompt) {
      const response = password.value;
      password.value = '';
      password.type = 'password';
      password.setAttribute('autocomplete', 'current-password');
      awaitingPrompt = false;
      loginButton.setAttribute('aria-label', 'Entrar');
      loginButton.title = 'Entrar';
      setBusy(true);
      setMessage('Aguardando resposta do LightDM…');
      lightdm.respond(response);
      return;
    }
    if (authenticating) return;
    if (!activeUsername) { setMessage('O LightDM não informou a conta configurada.', 'error'); return; }
    pendingSecret = password.value;
    userMenu.hidden = true;
    userTrigger.setAttribute('aria-expanded', 'false');
    password.value = '';
    setBusy(true);
    setMessage('Aguardando o serviço de autenticação…');
    try { lightdm.authenticate(activeUsername); }
    catch (error) {
      pendingSecret = '';
      setBusy(false);
      setMessage('O LightDM não iniciou a autenticação.', 'error');
      password.focus();
    }
  });
  restartButton.addEventListener('click', () => { if (hasLightDM && lightdm.can_restart) lightdm.restart(); });
  shutdownButton.addEventListener('click', () => { if (hasLightDM && lightdm.can_shutdown) lightdm.shutdown(); });
})();
