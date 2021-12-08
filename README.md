# internship

https://25thandclement.com/~william/projects/luaossl.pdf

https://www.antdv.com/docs/vue/introduce/

https://github.com/zhaojh329/oui


1. Simple (learning vue.js and lua using openwrt, testing config files)
No elements in Vuci form, cause screenshot was taken really late and test config file was deleted.
![image](https://user-images.githubusercontent.com/67824760/145180891-74c2a2b4-fd9c-44d9-a861-3be822143b03.png)

2. Login changes, learning about Vue.js router, to change the principle of login. First we find out how the password is saved, it is a simple salting method where you add a username to a password and hash it with MD5, it isnt secure, but we use this knowledge to save a default password. And use it for our login. With router we check beforeEach route if default password was changed or no. We track it with id in config file.
![image](https://user-images.githubusercontent.com/67824760/145181625-77c68188-0650-4507-bfca-fc43e8ef1525.png)

3.Info drawer set to the side of the page, it was achieved by using vuci-layout. 
![image](https://user-images.githubusercontent.com/67824760/145181830-0382a1f6-cafa-4b91-b568-4e70c4936d5f.png)

4.Vuci-app-configvpn
Module that lets the user to create and manage vpn configs, data display is made without using lua code, this made updating the table harder after each change outside of the table(in the input/edit modal)
![image](https://user-images.githubusercontent.com/67824760/145182345-b797868f-458d-4cf0-8401-7ae818c525e5.png)
To display the status, for the server we use ubus service list call and change the values based on response and for the client we take information from client log file using lua. While adding new openvpn config we are instantly creating a section and setting some key values for the modal to function.
Modal it is either add or edit, the only change is that edit has existing values.
Since we instantly set if its client or server, modal gets the fields based on that. We can change tls or skey authentication in modal, during the change the config values that were already asigned get deleted, same with uploaded files to prevent unwanted data being saved.
![image](https://user-images.githubusercontent.com/67824760/145183438-34d50d56-020d-46ad-be1b-6b08c1821fb6.png)
![image](https://user-images.githubusercontent.com/67824760/145183497-92af7df8-13f9-4f83-8841-30d8c1628e12.png)

5. Certificate generation using lua openssl. After quite a bit of researching managed to generate CA, public key and private key, after some testing understood that this library does not let me generate DH, so it kind just went back to generation using os.execute(). There is a /download method in the ui, still researching it since it doesnt work as intended.

