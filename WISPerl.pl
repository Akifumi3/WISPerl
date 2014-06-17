use LWP::UserAgent;
use HTTP::Request::Common;

$ua = LWP::UserAgent->new;
$ua->agent("myClient/1.0");

#初期設定
my $Username = "testuser@hoge.com"
my $Password = "testPassword";


#メイン処理
my $req = HTTP::Request->new(GET => 'http://google.com');
$req->content_type('application/x-www-form-urlencoded');
my $res = $ua->request($req);

if ($res->is_success) {
     my $content = $res->content;
     my $LoginUrl = &findLoginUrl($content);
     if(index($LoginUrl,"https://") == -1){
	 print "Already logged in\n";#or not secure server
	 exit;
     }

     my $reqPost = HTTP::Request->new(POST => $LoginUrl);

     $reqPost->content_type('application/x-www-form-urlencoded');
     $reqPost->content("UserName=$Username\&Password=$Password");
     
     my $resPost = $ua->request($reqPost);
     my $resPostcontent = $resPost->content;

     if($resPost->code($code) == 200){
	 print "POST successful\n";
	 my @result = &checkMTRC($resPostcontent);
	 if(@result[0] == 120 && @result[1] == 50){
	     print "Login succceed\n";
	     print "logoffURL ".@result[2];
	 }else{
	     print "Login failed\n";
	     print "MessageType : ".@result[0]."\n";
	     print "ResponseCode :".@result[1]."\n";
	 }

     }


}else{
    print $res->status_line, "\n";
}

END {
system('cmd /c pause');
}


sub findLoginUrl{
    my $temps = index($_[0],'<LoginURL>');
    my $tempe = index($_[0],'</LoginURL>');
    if($temps == -1){
	return 0;
    }

    return substr($_[0],$temps+10,$tempe-$temps-10)."\n";
}

############################################
# message type
# response code
##########################################
sub checkMTRC{
    my $tempMTs = index($_[0],'<MessageType>');
    my $tempMTe = index($_[0],'</MessageType>');
    my $tempRCs = index($_[0],'<ResponseCode>');
    my $tempRCe = index($_[0],'</ResponseCode>');

    if(($tempMTs == -1 )||($tempMTe == -1 )||($tempRCs == -1 )||($tempRCe == -1 )){
	return 0;
    }
    my @mtrc = (substr($_[0],$tempMTs+13,$tempMTe-$tempMTs-13),
		substr($_[0],$tempRCs+14,$tempRCe-$tempRCs-14));
    if(@mtrc[0] == 120 && @mtrc[1] ==50){
	push @mtrc,substr($_[0],index($_[0],"<LogoffURL>")+11,index($_[0],"</LogoffURL>") - index($_[0],"<LogoffURL>")-11);

    }
    return @mtrc;

}




