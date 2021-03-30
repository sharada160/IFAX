from O365 import Account
from O365 import MSGraphProtocol 
from O365.message import Message
from O365.mailbox import MailBox
import time,select
#credentials = ('my_client_id', 'my_client_secret')
#credentials = ('42a56f23-f453-441d-88e3-3acb123e511c', '1Gi_.VGTn15FQrjMe~pkQ1_B2_zHeXW58W')
try:
	credentials = ('3f708f99-56a8-42e3-a606-70dcdc7dfc92', 'YHqg8CVt~62w1rm0BJp-jbT3Vm1NIy5~~D')
#scp = ['https://graph.microsoft.com/.default']

	scp = ["https://graph.microsoft.com/Mail.Send"]
# the default protocol will be Microsoft Graph
# the default authentication method will be "on behalf of a user"

#account = Account(credentials)
#account = Account(credentials, auth_flow_type='credentials', tenant_id='29d0dd74-80aa-401f-8e81-a864b29c30bd')
	account = Account(credentials, auth_flow_type='credentials', tenant_id='57192160-2d87-4183-b297-a03d2e69f430')

#if account.authenticate():
#if account.authenticate(scopes=scp):

#protocol_graph = MSGraphProtocol()
#scopes_graph = protocol.get_scopes_for('message all')
# scopes here are: ['https://graph.microsoft.com/Mail.ReadWrite', 'https://graph.microsoft.com/Mail.Send']
#account = Account(credentials, scopes=scopes_graph)

	fromAddress = "demouser1@smtpclientdemo.onmicrosoft.com"
	toAddressList = ["lokesh.padmanabhaiah@toshiba-tsip.com"]

	if account.authenticate():
		print("Bingo!! Authenticated!")

    #m = account.new_message("demouser1@smtpclientdemo.onmicrosoft.com")
		m = account.new_message(fromAddress)
		print("New Message m is created... m type is ", type(m))
		m.sender.address = fromAddress
		m.to.add(toAddressList)
		m.body = 'Test Mail from python OAUTH2 api. With Attachment'
		m.subject = "Test mail from script_123"
		print("m.attachment type is ", type(m.attachments))
    #m.attachments.add("./attachments/send1.pdf")
    #m.send()

		print("Email sent successfully...")
		mailbox = account.mailbox(fromAddress)
		inbox = mailbox.inbox_folder()
    
		print("Messages from Inbox are as follows...")
		print("-----------------------------------")
		index = 0
		for message in inbox.get_messages():
			index = index + 1
        #print(message)
        #print("Message Body ",	message.body)
			print("To:  ",	message.to.add)
			print("Subject:", message.subject)
			print("Attachment ")
			print ("Attachment type is " , type(message.attachments))
			print ("Saving attachment as eml file... ")
			fileName="Bingo" + str(index )+ ".eml"
        #message.save_as_eml(fileName)
			print("Mime content is " , type(message.get_mime_content()))
			print("Message type is ", type(message))
			print("Messaget attachment type is ", type(message.attachments.download_attachments()), "Value is ", message.attachments.download_attachments())
			print("************************************")
			if message.attachments.download_attachments():            
				print("you somehow need to get the total count... to save all attachments", type(message.attachments))
				for fileAttachment in message.attachments:
					print("INside loop..... to save attachments..... ")
					fileAttachment.save()
				print("All attachment for this mail is saved.... now deleting this....")
            #message.delete()
			else:
				print("There is no attachment for this email")
            polling_wait = lambda x: select.select([],[],[],x)
            polling_wait(5) 
			print("Now will delete this message.... ")
			print("To Delete this email, uncomment next line in script...")
        #message.delete()
        
        
		print("-----------------------------------")
    
    
    #sent_folder = mailbox.sent_folder()
    #for message in sent_folder.get_messages():
	#    print(message)
	else:
		print("NOT AUTHENTICATED....")
except NameError:
    print("var not defined/wrong address")
except RuntimeError:
    print("run time error")
except SyntaxError as err:
    raise SyntaxError("Synatx") from err
except OSError:
    print("file not found")
except ImportError:
    print(" Import error")
except KeyboardInterrupt as key:
    raise KeyboardInterrupt("Keyboard Interrupt") from key
except TimeoutError:
    print("Time Out error")
except OSError as exc:
    raise OSError("failed to save file") from exc
except FileNotFoundError:
    print("file not found")
except :
    print("error")


