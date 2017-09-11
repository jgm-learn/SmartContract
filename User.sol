pragma solidity ^0.4.5;
 
import "./ID.sol";
import "./Quotation.sol";
import "./UserList.sol";

contract User
{
    //�ֵ����ݽṹ
    struct Receipt
    {
        string      user_id_;       //�ͻ�id
        uint        receipt_id_;    //�ֵ����
        string      class_id_;      //Ʒ��id
        string      make_date_;     //����
        string      lev_id_;        //�ȼ�
        string      wh_id_;         //�ֿ����
        string      place_id_;      //���ش���
        uint        receipt_amount_;  //�ֵ�����
        uint        frozen_amount_;   //��������   
        uint        available_amount_;//��������
        bool        state_;          //�Ƿ����
    }
     
    //�����������ݽṹ
    struct list_req_st
    {
         uint       receipt_id_;    //�ֵ����
         uint       quo_id_;        //�ҵ����
         uint       price_;         //�۸񣨴��渡���ͣ�
         uint       quo_qty_;       //������
         uint       deal_qty_;      //�ɽ���
         uint       rem_qty_;       //ʣ����
    }
    
    //��ͬ���ݽṹ
    struct contract_st
    {
        uint        con_data_;          //��ͬ����
        uint        con_id_;            //��ͬ���
        uint        receipt_id_;        //�ֵ����
        string      buy_or_sell_;       //����
        uint        price_;             //�۸�
        uint        con_qty_;           //��ͬ��
        //uint        fee_;               //������
        //uint        transfer_money_;    //�ѻ�����
        //uint        remainder_money_;   //ʣ�����
        string      user_id_;           //����id
        string      countparty_id_;     //���ַ�id
        //string      trade_state_;       //����״̬
        //string      trade_type_         //���׷�ʽ
    }   
    
    //Э�̽����������ݽṹ ����
    struct neg_req_send_st
    {
        uint        receipt_id_;    //�ֵ����
        uint        quantity_;      //��������
        uint        price_;         //�۸�
        uint        negotiate_id_;  //Э�̱��
        string      counterparty_id_;//���ַ�id
        string      trade_state;    //�ɽ�״̬
    }
    
    //Э�̽����������ݽṹ ����
    struct neg_req_receive_st
    {
        uint        receipt_id_;        //�ֵ����
        uint        quantity_;          //��������
        uint        price_;             //�۸�
        uint        negotiate_id_;      //Э�̱��
        string      counterparty_id_;   //���ַ�id
        address     sell_con_addr_;     //�����ĺ�Լ��ַ
        string      trade_state;        //�ɽ�״̬
    }
    
    
    
     Quotation                          quatation;          //�����Լ����
     ID_contract                        ID;                 //ID��Լ����
     UserList                           user_list;          //�û��б��Լ����
     
     //�洢�ֵ�     
     mapping(uint => Receipt)           ReceiptMap;         //�ֵ�ID => �ֵ�
        
     //�洢��������     
     list_req_st[]                      list_req_array;     
     
     //�洢��ͬ
     mapping(uint => contract_st)       contract_map;       //��ͬ��� => ��ͬ
     
     //Э�̽��������б�
     neg_req_send_st[]                  neg_req_send_array; 
     neg_req_receive_st[]               neg_req_receive_array; 
     
     
   
     
     //��ӡ������Ϣ
     event error(string,string, uint);
     
     event inform(string);
     
     
     
     //���캯��
     function User(address id_addr, address quo_addr, address user_list_addr)
     {
         ID         =   ID_contract(id_addr);
         quatation  =   Quotation(quo_addr);
         user_list  =   UserList(user_list_addr);
     }
     
    //����ֵ� "A",0,"sugar","2017","lev","wh_id","place",30
   function CreateRecipt(string user_id, uint receipt_id, string class_id,string make_date,
                        string lev_id, string wh_id, string place_id,  uint receipt_amount)
    {
        
        ReceiptMap[receipt_id] = Receipt(user_id, receipt_id,class_id, make_date, lev_id, 
                                        wh_id, place_id, receipt_amount,0,receipt_amount,true);
    }
    
    //��ȡ�����ߵĲֵ�����
    function getReceiptAmount(uint receipt_id) returns (uint)
    {
        return ReceiptMap[receipt_id].receipt_amount_;
    }
    
     //��ȡ���òֵ�����
    function getAvailableAmount(uint receipt_id) returns (uint)
    {
        return ReceiptMap[receipt_id].available_amount_;
    }
    
    //���ٳ����ߵĲֵ�����
    function reduceuint (uint receipt_id, uint reduece_amount) returns (bool)
    {
        if( reduece_amount > ReceiptMap[receipt_id].receipt_amount_ )
            return false;
       
         ReceiptMap[receipt_id].receipt_amount_ -= reduece_amount;
         return true;
    } 
    
     //���ӳ����ߵĲֵ�����
    function increase(uint receipt_id, uint increase_amount)
    {
         ReceiptMap[receipt_id].receipt_amount_ += increase_amount;
         ReceiptMap[receipt_id].receipt_amount_ += increase_amount;
    }
    
    //����ֵ�
    function freeze(uint receipt_id, uint amount) returns (bool)
    {
        if( amount > ReceiptMap[receipt_id].receipt_amount_ )
            return false;
         ReceiptMap[receipt_id].frozen_amount_    += amount;
         ReceiptMap[receipt_id].available_amount_ -= amount;
         
         return true;
    }

    
    
    
    //�������� "zhang",0,10,20
    function ListRequire(string user_id, uint receipt_id, uint price, uint quo_qty) returns(uint quo_id )
    {
        if(ReceiptMap[receipt_id].state_ == false)
        {
             error("ListRequire():�ֵ���Ų�����","������룺",uint(-2));
             return uint(-2);
        }
        if(quo_qty > ReceiptMap[receipt_id].available_amount_)  
         {
             error("ListRequire():���òֵ���������","������룺",uint(-3));
             return uint(-3);
        }
        
        freeze(receipt_id, quo_qty);//����ֵ�
        
        quatation.insert_list_1(receipt_id, "�ο���Լ", ReceiptMap[receipt_id].class_id_, ReceiptMap[receipt_id].make_date_,
                                ReceiptMap[receipt_id].lev_id_,ReceiptMap[receipt_id].wh_id_,ReceiptMap[receipt_id].place_id_);
                                
        quo_id = quatation.insert_list_2(price, quo_qty, 0, quo_qty, 1000, "���ƽ�ֹ��",6039, user_id);
        
        if(quo_id >0)
        {
            freeze(receipt_id, quo_qty);        //����ֵ�
        }
        
        //��ӹ�������
        list_req_array.push( list_req_st(receipt_id, quo_id, price, quo_qty, 0, quo_qty) ); 
    }
    
    //����������������
    function update_list_req(uint quo_id, uint deal_qty)
    {
        for(uint i = 0; i<list_req_array.length; i++)
        {
            if(list_req_array[i].quo_id_ == quo_id)
            {
                list_req_array[i].deal_qty_      =      deal_qty;
                list_req_array[i].rem_qty_       -=     deal_qty;
                break;
            }
        }
        
    }
    
    //ժ������ "li",1,10
    function delist_require(string user_id, uint quo_id, uint deal_qty) 
    {
        quatation.delist(user_id, quo_id, deal_qty);
    }
    
    //�ɽ� ������ͬ
    function deal_contract(uint  receipt_id, string  buy_or_sell, uint price, uint con_qty, string countparty_id)
    {
        uint con_id = ID.contract_id();//��ȡ��ͬ���
        
        contract_map[con_id].con_data_ = now;
        contract_map[con_id].con_id_ = con_id;
        contract_map[con_id].receipt_id_ = receipt_id;
        contract_map[con_id].buy_or_sell_ = buy_or_sell;
        contract_map[con_id].price_ = price;
        contract_map[con_id].con_qty_ = con_qty;
        contract_map[con_id].countparty_id_ = countparty_id;
        
        inform("�ɹ�������ͬ�����״��");
    }
    

    
    
    //����Э�̽������� ��������
    function send_negotiate_req(uint receipt_id, uint price, 
                                uint quantity, string counterparty_id) returns(uint)
    {
        if(quantity > ReceiptMap[receipt_id].available_amount_)
        {
            error("negotiate_req():���òֵ���������","�������:",uint(-1));
            return uint(-1);
        }
        
        //����ֵ�
        freeze(receipt_id, quantity);
        
        
        uint    neg_id = ID.negotiate_id();//Э�̽��ױ��
        
        //����Э�̽��������б����ͣ�
        neg_req_send_array.push( neg_req_send_st(receipt_id,quantity,price,
                                neg_id,counterparty_id,"δ�ɽ�") );
       
        //���ö��ַ�Э�̽�������Ľ��շ���
        User counterparty =  User( user_list.GetUserConAddr(counterparty_id) );
        counterparty.recieve_negotiate_req(receipt_id,quantity,price,
                                neg_id, ReceiptMap[receipt_id].user_id_);
        
        
    }
    
    
    //����Э�̽������� ��������
    function recieve_negotiate_req(uint receipt_id, uint price, uint quantity, 
                                    uint neg_id,string counterparty_id)
    {
        neg_req_receive_array.push( neg_req_receive_st(receipt_id,quantity,price,
                                neg_id,counterparty_id,msg.sender,"δ�ɽ�") );
    }
    
     //ȷ��Э�̽��� �򷽵��ô˺���
    function agree_negotiate(string user_id, uint  receipt_id,  uint price,
                                uint con_qty, string countparty_id)
    {
        //�����򷽺�ͬ
        deal_contract(receipt_id, "��", price,con_qty,countparty_id);
        
        //
        for(uint i= 0; i<neg_req_receive_array.length; i++ )
        {
            if(neg_req_receive_array[i].receipt_id_ == receipt_id)
                break;
        }
        //����������ͬ
        User user_sell = User(neg_req_receive_array[i].sell_con_addr_);
        user_sell.deal_contract(receipt_id, "��", price,con_qty,user_id);
    }
    
}




















