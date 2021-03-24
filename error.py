from O365 import Account
from O365 import MSGraphProtocol 
from O365.message import Message
from O365.mailbox import MailBox
import polling2,time
import select
#credentials = ('3f708f99-56a8-42e3-a606-70dcdc7dfc92', 'YHqg8CVt~62w1rm0BJp-jbT3Vm1NIy5~~D')
#account = Account(credentials, auth_flow_type='credentials', tenant_id='57192160-2d87-4183-b297-a03d2e69f430')
try:
    credentials = ('829c44f7-ea4c-46d7-bb3f-e0e578d78e55', 'I-xmubeV-i4-6GE~Ap-oeqEx6-6.OjQP15')
    account = Account(credentials, auth_flow_type='credentials', tenant_id='a78efe84-fbe2-4385-aa24-2e019f6d8480')
#fromAddress = "demouser1@smtpclientdemo.onmicrosoft.com"
    fromAddress="sample@sharada98s.onmicrosoft.com"
    toAddressList = ["sharada98s@gmail.com"]  
    if account.authenticate():
        print("Bingo!! Authenticated!")
        try: 
            m = account.new_message(fromAddress)    
            m.sender.address = fromAddress
            m.to.add(toAddressList)
            m.body = 'Test Mail from python OAUTH2 api. With Attachment'
            m.subject = "Test mail from script_123"
            m.attachments.add("./Downloads/A Sample PDF.pdf")
            m.send()
        except FileNotFoundError:
            print("file not found")
        print("Email sent successfully...")
        mailbox = account.mailbox(fromAddress)
        inbox = mailbox.inbox_folder()
        print("Messages from Inbox are as follows...")
        print("-----------------------------------")
        index = 0
        for message in inbox.get_messages():
            index = index + 1
            try:
                print("Subject:", message.subject)        
                print("************************************")
                if message.attachments.download_attachments():                       
                    for fileAttachment in message.attachments:                
                        try:
                            fileAttachment.save("./Documents")
                        except OSError as exc:
                            raise OSError("failed to save file") from exc
                    #print("All attachment for this mail is saved.... now deleting this....")
                    #print("To Delete this email, uncomment next line in script...")
                    #message.delete()
                else:
                    print("There is no attachment for this email") 
            #print("Now will delete this message.... ")
            #print("To Delete this email, uncomment next line in script...")
            #message.delete() 
                polling_wait = lambda x: select.select([],[],[],x)
                polling_wait(5)
            except ImportError:
                print(" Import error")
            except KeyboardInterrupt as key:
                raise KeyboardInterrupt("Keyboard Interrupt") from key
            except TimeoutError:
                print("Time Out error")
            except :
                print("error")
        print("-----------------------------------")  
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



