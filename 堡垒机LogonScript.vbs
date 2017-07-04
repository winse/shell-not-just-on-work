#$language = "VBScript"
#$interface = "1.0"

crt.Screen.Synchronous = True

Sub Main
  ' 可以先通过录制脚本生成一部分代码，然后再进行修改.
  crt.Screen.Send chr(13)
  crt.Screen.Send chr(27) & "OB" & chr(13)
  crt.Screen.Send chr(13)
  crt.Screen.Send chr(13)
  
  crt.Screen.WaitForString "$ "
  crt.Screen.Send "hostname" & chr(13)
  crt.Screen.WaitForString "$ "
  crt.Screen.Send "ssh -N -R 9999:localhost:项目A服务器SSH端口 用户@项目A服务器地址" & chr(13)
  crt.Screen.WaitForString "password:"
  crt.Screen.Send "公司跳板机密码" & chr(13)
  
  ' 参数：相对于SESSION目录C:\Users\winse\AppData\Roaming\VanDyke\Config\Sessions的相对路径，去掉ini后缀
  
  ' 这个连接配置Port Forwarding: Name 项目A / Local Address 19999 / Remote Host 127.0.0.1:9999
  crt.OpenSessionConfiguration("公司\跳板机\123456").ConnectInTab()
  
  ' 配置SSH2： Hostname 127.0.0.1 / Port 19999 / 项目A服务器用户
  crt.OpenSessionConfiguration("项目A\中转跳板机").ConnectInTab()
End Sub
