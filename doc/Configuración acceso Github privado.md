# 🚀 Configuración de acceso SSH a repositorio privado en GitHub

Este documento describe el procedimiento completo para configurar un servidor que pueda clonar un repositorio privado de GitHub sin necesidad de ingresar credenciales.

---

## 🧩 1️⃣ Crear carpeta para las claves SSH

Ejecutar en PowerShell para crear la carpeta donde se guardarán las claves:

```powershell
mkdir $env:USERPROFILE\.ssh -ErrorAction SilentlyContinue
```

---

## 🧩 2️⃣ Generar la clave SSH

Generar una clave SSH dedicada para este servidor:

```powershell
ssh-keygen -t ed25519 -C "deploy-key-servidor" -f $env:USERPROFILE\.ssh\id_deploy_repo
```

Dejar la passphrase vacía si se requiere acceso automático.

---

## 🧩 3️⃣ Mostrar la clave pública

Mostrar y copiar la clave pública:

```powershell
cat $env:USERPROFILE\.ssh\id_deploy_repo.pub
```

---

## 🧩 4️⃣ Agregar la Deploy Key en GitHub

1. Ir al repositorio de GitHub: **Settings → Deploy keys → Add deploy key**
2. Pegar la clave pública copiada.
3. Dejar **Allow write access** desmarcado si solo se requiere lectura.
4. Guardar.

---

## 🧩 5️⃣ Probar conexión SSH con GitHub

```powershell
ssh -i $env:USERPROFILE\.ssh\id_deploy_repo -T git@github.com
```

Debe mostrar un mensaje como:

```
Hi usuario! You've successfully authenticated, but GitHub does not provide shell access.
```

---

## 🧩 6️⃣ Configurar `~/.ssh/config`

Para no tener que indicar la clave cada vez, crear el archivo de configuración:

```powershell
notepad $env:USERPROFILE\.ssh\config
```

Pegar el siguiente contenido:

```
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_deploy_repo
    IdentitiesOnly yes
```

---

## 🧩 7️⃣ Agregar GitHub a `known_hosts`

Evita que pregunte la primera vez:

```powershell
ssh-keyscan github.com >> $env:USERPROFILE\.ssh\known_hosts
```

---

## 🧩 8️⃣ Clonar el repositorio

Clonar el repositorio de forma segura:

```powershell
git clone git@github.com:hrodriguezhenry/airflow-etl.git
```

---

## 🧩 9️⃣ Buenas prácticas

- No compartir la clave privada.
- Revocar la deploy key si el servidor se compromete.
- Usar claves Ed25519 por seguridad y rendimiento.
- Crear claves distintas por servidor o proyecto si se requiere.

---

## 🧩 🔁 Resumen rápido de comandos

```powershell
mkdir $env:USERPROFILE\.ssh -ErrorAction SilentlyContinue
ssh-keygen -t ed25519 -C "deploy-key-servidor" -f $env:USERPROFILE\.ssh\id_deploy_repo
cat $env:USERPROFILE\.ssh\id_deploy_repo.pub
notepad $env:USERPROFILE\.ssh\config
ssh-keyscan github.com >> $env:USERPROFILE\.ssh\known_hosts
ssh -T git@github.com
git clone git@github.com:hrodriguezhenry/airflow-etl.git
```

---

✅ **Resultado final:**  
Tu servidor estará configurado para clonar y actualizar repositorios privados de GitHub sin ingresar credenciales manualmente, de forma segura y automatizada.
