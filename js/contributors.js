$(function(){
    $.ajax({
        url: 'https://api.github.com/repos/napalm255/powerbash/contributors',
        dataType: 'jsonp',
        success: function(data) {
            var items = [];

            $.each(data.data, function(key, val) {
                items.push('<li><a href="' + val.html_url + '" rel="avatarover" data-placement="top" data-title="' + val.login + '" data-content="' + val.login + ' has made ' + val.contributions + ' contributions to powerbash"><img src="' + val.avatar_url + '" width="32" height="32" /></a></li>');
});

            $('<ul/>', {
                'class': 'contributor-list',
                html: items.join('')
            }).appendTo('#contributors');
            $('[rel=avatarover]').popover();
        }
    });

});
