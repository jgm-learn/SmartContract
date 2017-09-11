pragma solidity ^0.4.5;

import "./User.sol";

contract Quotation
{
    struct data_st
    {
        uint        quo_date_;      //��������
        uint        receipt_id_;    //�ֵ����
        string      ref_contract_;  //�ο���Լ
        string      class_id_;      //Ʒ�ִ���
        string      make_date_;     //����
        string      lev_id_;        //�ȼ�
        string      wh_id_;         //�ֿ����
        string      place_id_;      //���ش���
        string      quo_type_;      //��������
        uint        price_;         //�۸񣨴��渡���ͣ�
        uint        quo_qty_;       //������
        uint        deal_qty_;      //�ɽ���
        uint        rem_qty_;       //ʣ����
        uint        wr_premium_;    //�ֵ�����ˮ
        string      quo_deadline_;  //���ƽ�ֹ��
        uint        dlv_unit_;      //���λ
        string      user_id_;       //�û�id
        address     seller_addr_;   //������ַ
        bool        state;          //�Ƿ����
    }
    
    uint                        quo_id_ = 0; //�ҵ���Ŵ� 1 ��ʼ
    mapping(uint => data_st)    data_map;   //�ҵ���� => �ҵ�����
    
    //������� 
    event   print_1( uint,uint,string,string,string,string,string,string);
    event   print_2(string, uint,uint,uint,uint,uint,string,uint, string );
    
    //��ӡ������Ϣ
    event   error(string,string,string);
    
    //��������           
    function insert_list_1(uint receipt_id,
                        string  ref_contract, string  class_id, string  make_date,   
                        string  lev_id, string  wh_id, string  place_id)
    {
         quo_id_++;//�ҵ����
         
        data_map[quo_id_].quo_date_ = now;
        data_map[quo_id_].receipt_id_ = receipt_id;
        data_map[quo_id_].ref_contract_ = ref_contract;
        data_map[quo_id_].class_id_ = class_id;
        data_map[quo_id_].make_date_ = make_date;
        data_map[quo_id_].lev_id_ = lev_id;
        data_map[quo_id_].wh_id_ = wh_id;
        data_map[quo_id_].place_id_ = place_id;
        data_map[quo_id_].quo_type_ = "һ�ڼ�";
    }
    function insert_list_2(uint price, uint quo_qty, uint deal_qty,
                            uint rem_qty, uint wr_premium,  string  quo_deadline, 
                            uint dlv_unit, string user_id ) returns(uint)
    {
        data_map[quo_id_].price_ = price;
        data_map[quo_id_].quo_qty_ = quo_qty;
        data_map[quo_id_].deal_qty_ = deal_qty;
        data_map[quo_id_].rem_qty_ = rem_qty;
        data_map[quo_id_].wr_premium_ = wr_premium;
        data_map[quo_id_].quo_deadline_ = quo_deadline;
        data_map[quo_id_].dlv_unit_ = dlv_unit;
        data_map[quo_id_].user_id_ = user_id;
        data_map[quo_id_].seller_addr_ = msg.sender;
        data_map[quo_id_].state = true;  
            
            
        print_quotation();    
        
        //����ֵ�   
       // User user = User(msg.sender);
       // user.freeze( data_map[index_list].firm_sheet_id_,quo_qty);
            
        return quo_id_;
            
    }
    
    //��ӡ����
    function print_quotation()
    {
        print_1(
                data_map[quo_id_].quo_date_,
                data_map[quo_id_].receipt_id_, 
                data_map[quo_id_].ref_contract_,
                data_map[quo_id_].class_id_,
                data_map[quo_id_].make_date_,
                data_map[quo_id_].lev_id_,
                data_map[quo_id_].wh_id_,
                data_map[quo_id_].place_id_
            );
            
        print_2(
                data_map[quo_id_].quo_type_,
                data_map[quo_id_].price_,
                data_map[quo_id_].quo_qty_ ,
                data_map[quo_id_].deal_qty_,
                data_map[quo_id_].rem_qty_ ,
                data_map[quo_id_].wr_premium_,
                data_map[quo_id_].quo_deadline_,
                data_map[quo_id_].dlv_unit_,
                data_map[quo_id_].user_id_
                );
    }
  
  
    //ժ��
    function delist(string user_id, uint quo_id, uint deal_qty) returns(uint)
    {
        if(deal_qty > data_map[quo_id].rem_qty_ )
        {
            error("delist():�ֵ�ʣ�������㣬ժ�Ƴ���","������룺","-1");
            return uint(-1);
        }
        
        //���³ɽ�����ʣ����
        data_map[quo_id].deal_qty_  =   deal_qty ;
        data_map[quo_id].rem_qty_   -=  deal_qty ;
        
        //����������������
        User user_sell = User(data_map[quo_id].seller_addr_);
        user_sell.update_list_req(quo_id, deal_qty);
        
        //����������ͬ
        user_sell.deal_contract(data_map[quo_id].receipt_id_, "��",  data_map[quo_id].price_, deal_qty, user_id);
        //�����򷽺�ͬ
        User user_buy = User(msg.sender);
        user_buy.deal_contract(data_map[quo_id].receipt_id_, "��",  data_map[quo_id].price_, deal_qty, data_map[quo_id].user_id_);
        
        //��ӡ����
        print_quotation();
        
        
    }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
    
}