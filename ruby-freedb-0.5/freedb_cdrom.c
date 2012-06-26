/* $Id: freedb_cdrom.c,v 1.5 2003/02/07 14:16:16 moumar Exp $ */
/*
 * Copyright (c) 1999,2001 Robert Woodcock <rcw@debian.org>
 * This code is hereby licensed for public consumption under either the
 * GNU GPL v2 or greater, or Larry Wall's Artistic license - your choice.

 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/ioctl.h>

#include <ruby.h>

/* Porting credits:
 * Solaris: David Champion <dgc@uchicago.edu>
 * FreeBSD: Niels Bakker <niels@bakker.net>
 * OpenBSD: Marcus Daniel <danielm@uni-muenster.de>
 * NetBSD: Chris Gilbert <chris@NetBSD.org>
 */

/* Modified for ruby/freedb by Guillaume Pierronnet <moumar@netcourrier.com> */

#if defined(OS_LINUX)
# include <linux/cdrom.h>

#elif defined(OS_SOLARIS)
# include <sys/cdio.h>
# define CD_MSF_OFFSET	150
# define CD_FRAMES	75

#elif defined(OS_FREEBSD)
#include <sys/cdio.h>
#define        CDROM_LBA       CD_LBA_FORMAT   /* first frame is 0 */
#define        CD_MSF_OFFSET   150     /* MSF offset of first frame */
#define        CD_FRAMES       75      /* per second */
#define        CDROM_LEADOUT   0xAA    /* leadout track */
#define        CDROMREADTOCHDR         CDIOREADTOCHEADER
#define        CDROMREADTOCENTRY       CDIOREADTOCENTRY
#define        cdrom_tochdr    ioc_toc_header
#define        cdth_trk0       starting_track
#define        cdth_trk1       ending_track
#define        cdrom_tocentry  ioc_read_toc_single_entry
#define        cdte_track      track
#define        cdte_format     address_format
#define        cdte_addr       entry.addr

#elif defined(OS_OPENBSD) || defined(OS_NETBSD)
#include <sys/cdio.h>
#define        CDROM_LBA       CD_LBA_FORMAT   /* first frame is 0 */
#define        CD_MSF_OFFSET   150     /* MSF offset of first frame */
#define        CD_FRAMES       75      /* per second */
#define        CDROM_LEADOUT   0xAA    /* leadout track */
#define        CDROMREADTOCHDR         CDIOREADTOCHEADER
#define        cdrom_tochdr    ioc_toc_header
#define        cdth_trk0       starting_track
#define        cdth_trk1       ending_track
#define        cdrom_tocentry  cd_toc_entry
#define        cdte_track      track
#define        cdte_addr       addr

#endif

VALUE cFreedb;

int cddb_sum (int n)
{
	/* a number like 2344 becomes 2+3+4+4 (13) */
	int ret=0;

	while (n > 0) {
		ret = ret + (n % 10);
		n = n / 10;
	}

	return ret;
}

/* 
 * Returns a valid DISCID for the CD in (device)
 */
static VALUE fdb_get_cdrom(VALUE self, VALUE device) {
  char str[1201];
#if defined(OS_OPENBSD) || defined(OS_NETBSD)
  struct ioc_read_toc_entry t;
#endif
  int len;
  int drive, i, totaltime;
  long int cksum=0;
  unsigned char first=1, last=1;
  struct cdrom_tochdr hdr;
  struct cdrom_tocentry *TocEntry;


  char offsets[1089] = "", buff[255];

  Check_SafeStr(device);
  drive = open(RSTRING(device)->ptr, O_RDONLY | O_NONBLOCK);

  if (drive < 0) {
    rb_sys_fail(RSTRING(device)->ptr);
  }

  if (ioctl(drive,CDROMREADTOCHDR,&hdr) < 0) {
    close(drive);
    rb_sys_fail("Failed to read TOC entry");
  }

  first=hdr.cdth_trk0;
  last=hdr.cdth_trk1;
  len = (last + 1) * sizeof (struct cdrom_tocentry);
/*	
	if (TocEntry) {
	  free(TocEntry);
	  TocEntry = 0;
	}
	*/
  TocEntry = malloc(len);
  if (!TocEntry) {
    close(drive);
    rb_sys_fail("Can't allocate memory for TOC entries");
  }
#if defined(OS_OPENBSD) 
  t.address_format = CDROM_LBA;
  t.starting_track = 0;
  t.data_len = len;
  t.data = TocEntry;

  if (ioctl(drive, CDIOREADTOCENTRYS, (char *) &t) < 0)
    free(TocEntry);
    close(drive);
    rb_sys_fail("Failed to read TOC entry");
  }
#elif defined(OS_NETBSD)
  t.address_format = CDROM_LBA;
  t.starting_track = 1;
  t.data_len = len;
  t.data = TocEntry;
  memset(TocEntry, 0, len);
	
  if(ioctl(drive, CDIOREADTOCENTRYS, (char *) &t) < 0) {
    free(TocEntry);
    close(drive);
    rb_sys_fail("Failed to read TOC entry");
  }
#else

  for (i=0; i < last; i++) {
    TocEntry[i].cdte_track = i + 1; /* tracks start with 1, but i must start with 0 on OpenBSD */
    TocEntry[i].cdte_format = CDROM_LBA;
    if (ioctl(drive, CDROMREADTOCENTRY, &TocEntry[i]) < 0) {
      free(TocEntry);
      close(drive);
      rb_sys_fail("Failed to read TOC entry");
    }
  }

  TocEntry[last].cdte_track = CDROM_LEADOUT;
  TocEntry[last].cdte_format = CDROM_LBA;
  if (ioctl(drive, CDROMREADTOCENTRY, &TocEntry[i]) < 0) {
    free(TocEntry);
    close(drive);
    rb_sys_fail("Failed to read TOC entry");
  }
#endif
  close(drive);

#if defined(OS_FREEBSD)
  TocEntry[i].cdte_addr.lba = ntohl(TocEntry[i].cdte_addr.lba);
#endif

  for (i=0; i < last; i++) {
#if defined(OS_FREEBSD)
    TocEntry[i].cdte_addr.lba = ntohl(TocEntry[i].cdte_addr.lba);
#endif
    cksum += cddb_sum((TocEntry[i].cdte_addr.lba + CD_MSF_OFFSET) / CD_FRAMES);
  }

  totaltime = ((TocEntry[last].cdte_addr.lba + CD_MSF_OFFSET) / CD_FRAMES) -
    ((TocEntry[0].cdte_addr.lba + CD_MSF_OFFSET) / CD_FRAMES);


  for (i = 0; i < last; i++) { /* write offsets */
    sprintf(buff, "%d ", TocEntry[i].cdte_addr.lba + CD_MSF_OFFSET);
    strcat(offsets, buff);
  }
	
  sprintf(buff,"%d", (TocEntry[last].cdte_addr.lba + CD_MSF_OFFSET) / CD_FRAMES);
  strcat(offsets, buff);

  sprintf(str, "%08lx %d %s", (cksum % 0xff) << 24 | totaltime << 8 | last, last, offsets);
	
  free(TocEntry);

  return rb_str_new2(str);
}

void Init_freedb_cdrom() {
  
  cFreedb = rb_define_class("Freedb", rb_cObject);
  rb_define_private_method(cFreedb, "get_cdrom", fdb_get_cdrom, 1);
  //rb_require("freedb_misc.rb");

}
